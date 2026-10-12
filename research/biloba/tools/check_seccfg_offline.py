"""Check saved seccfg against plain and known software-AES digest methods.

Failure of these two methods does not establish invalid hardware-backed seccfg.
Software method follows mtkclient sej_sec_cfg_sw; no hardware is accessed.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes



def audit(data):
    """Validate a V4 record and compare its trailing hash using offline methods."""
    if len(data) < 60:
        raise ValueError('Truncated V4 seccfg record')
    magic, version, size, _, _, _, endflag = struct.unpack_from('<7I', data)
    if magic != 0x4D4D4D4D or version != 4 or endflag != 0x45454545:
        raise ValueError('Unsupported V4 seccfg header')
    if size < 60 or size > len(data):
        raise ValueError('Invalid seccfg_size')
    stored = data[size-32:size]
    digest = hashlib.sha256(data[:28]).digest()
    decrypt = Cipher(algorithms.AES(b'25A1763A21BC854CD569DC23B4782B63'),
                     modes.CBC(bytes.fromhex('57325A5A125497661254976657325A5A'))).decryptor()
    decoded = decrypt.update(stored) + decrypt.finalize()
    return dict(header_sha256=digest.hex(), stored_hash_plain_matches=stored==digest,
                  software_aes_decrypted_hash_matches=decoded==digest,
                  hardware_crypto_validated=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    data = args.input.read_bytes()
    try:
        result = audit(data)
    except ValueError as error:
        parser.error(str(error))
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
