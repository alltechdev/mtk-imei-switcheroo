"""Regression tests for optional audits; synthetic fixtures, no firmware or device."""
import contextlib
import hashlib
import io
import json
import struct
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'research/biloba/tools'))
import check_bootloader_archive as bootloader
import check_seccfg_offline as seccfg
import check_signing_keys as signing
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec, ed25519, padding, rsa
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes


class AuditTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

    def test_rsa_verification_and_non_rsa_keys(self):
        message = b'audit regression'
        signature = self.key.sign(message, padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=32), hashes.SHA256())
        self.assertTrue(signing.verifies(self.key.public_key(), signature, message))
        self.assertFalse(signing.verifies(self.key.public_key(), signature, b'changed'))
        with tempfile.TemporaryDirectory() as tmp:
            archive = Path(tmp)/'keys.zip'
            keys = [self.key, ec.generate_private_key(ec.SECP256R1()), ed25519.Ed25519PrivateKey.generate()]
            with zipfile.ZipFile(archive, 'w') as z:
                for i, key in enumerate(keys):
                    z.writestr(f'{i}.pem', key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption()))
            groups, skipped = signing.load_archive_keys(archive)
            self.assertEqual(len(groups), 1)
            self.assertEqual([x['file'] for x in skipped], ['1.pem', '2.pem'])
            for key in keys[1:]:
                self.assertFalse(signing.verifies(key.public_key(), signature, message))

    def test_seccfg_hash_locations(self):
        for size in [60, 64, 128]:
            for encrypted in [False, True]:
                with self.subTest(size=size, encrypted=encrypted):
                    header = struct.pack('<7I', 0x4D4D4D4D, 4, size, 3, 0, 0, 0x45454545)
                    stored = hashlib.sha256(header).digest()
                    if encrypted:
                        cipher = Cipher(algorithms.AES(b'25A1763A21BC854CD569DC23B4782B63'), modes.CBC(bytes.fromhex('57325A5A125497661254976657325A5A'))).encryptor()
                        stored = cipher.update(stored) + cipher.finalize()
                    record = header + b'\0'*(size-60) + stored + b'partition padding'
                    result = seccfg.audit(record)
                    self.assertEqual(result['stored_hash_plain_matches'], not encrypted)
                    self.assertEqual(result['software_aes_decrypted_hash_matches'], encrypted)
                    self.assertFalse(result['hardware_crypto_validated'])

    def test_seccfg_rejects_bad_headers_and_sizes(self):
        valid = [0x4D4D4D4D, 4, 60, 3, 0, 0, 0x45454545]
        for index, value in [(0, 0), (1, 3), (2, 59), (2, 1000), (6, 0)]:
            with self.subTest(index=index, value=value):
                header = valid.copy()
                header[index] = value
                with self.assertRaises(ValueError):
                    seccfg.audit(struct.pack('<7I', *header) + bytes(32))
        with self.assertRaises(ValueError):
            seccfg.audit(bytes(59))

    def test_zip_crc_failure_is_incomplete_and_nonzero(self):
        with tempfile.TemporaryDirectory() as tmp:
            work = Path(tmp)
            (work/'members').mkdir()
            (work/'verification').mkdir()
            # Only public-key fields are consumed by the archive scanner.
            der = signing.public_bytes(self.key.public_key())
            cert = bytearray(1024)
            for offset in [181, 496]:
                cert[offset:offset+len(der)] = der
            (work/'members/2_cert1').write_bytes(cert)
            archive = work/'bootloader.zip'
            with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_STORED) as z:
                z.writestr('key.txt', b'CRC regression payload')
            argv = ['audit', '--work', str(work), '--archive', str(archive)]
            with patch.object(sys, 'argv', argv), contextlib.redirect_stdout(io.StringIO()):
                bootloader.main()
            report = work/'verification/bootloader_keys.json'
            self.assertEqual(json.loads(report.read_text())['status'], 'complete')
            data = archive.read_bytes().replace(b'CRC regression payload', b'CRC regression payloae')
            archive.write_bytes(data)
            with patch.object(sys, 'argv', argv), contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    bootloader.main()
            self.assertNotEqual(error.exception.code, 0)
            result = json.loads(report.read_text())
            self.assertEqual(result['status'], 'incomplete')
            self.assertEqual(result['read_errors'], [{'file': 'key.txt', 'error': 'BadZipFile'}])


if __name__ == '__main__':
    unittest.main()
