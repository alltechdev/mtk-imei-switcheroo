"""Check saved seccfg against plain and known software-AES digest methods.

Failure of these two methods does not establish invalid hardware-backed seccfg.
Software method follows mtkclient sej_sec_cfg_sw; no hardware is accessed.
"""
import argparse
import hashlib
import json
from pathlib import Path
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes



def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    data = args.input.read_bytes()
    digest = hashlib.sha256(data[:28]).digest()
    decrypt = Cipher(algorithms.AES(b'25A1763A21BC854CD569DC23B4782B63'),
                     modes.CBC(bytes.fromhex('57325A5A125497661254976657325A5A'))).decryptor()
    decoded = decrypt.update(data[28:60]) + decrypt.finalize()
    result = dict(header_sha256=digest.hex(), stored_hash_plain_matches=data[28:60]==digest,
                  software_aes_decrypted_hash_matches=decoded==digest,
                  hardware_crypto_validated=False)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
