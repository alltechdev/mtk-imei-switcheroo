"""Inspect a bootloader source ZIP for matching public/private signing keys.

No extraction or archive-code execution. Skip bitmap artwork and do not
recurse into nested archives. Only public metadata is saved.
"""
import hashlib
import argparse
import json
import re
import zipfile
from pathlib import Path

from cryptography import x509
from cryptography.hazmat.primitives import serialization
from check_signing_keys import tlv, public_bytes

ARCHIVE = None
PEM = re.compile(rb'-----BEGIN ([A-Z0-9 ]+)-----.*?-----END \1-----', re.S)


def main():
    global ARCHIVE
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=Path, required=True)
    parser.add_argument('--work', type=Path, required=True)
    args = parser.parse_args()
    ARCHIVE = args.archive
    ROOT = args.work.resolve()
    cert = (ROOT/'members/2_cert1').read_bytes()
    targets = {}
    for off in (181, 496):
        _, _, end = tlv(cert, off)
        pub = serialization.load_der_public_key(cert[off:end])
        der = public_bytes(pub)
        modulus = pub.public_numbers().n.to_bytes(pub.key_size//8, 'big')
        targets[hashlib.sha256(der).hexdigest()] = (der, modulus)
    inventory = []
    raw_hits = []
    errors = []
    skipped = []
    nested = []
    parsed_cache = {}
    count = total = 0
    with zipfile.ZipFile(ARCHIVE) as z:
        for entry in z.infolist():
            if entry.is_dir():
                continue
            suffix = Path(entry.filename).suffix.lower()
            if suffix == '.bmp':
                skipped.append({'file': entry.filename, 'bytes': entry.file_size})
                continue
            if suffix in {'.zip', '.gz', '.xz', '.7z', '.tar'}:
                nested.append(entry.filename)
            try:
                data = z.read(entry)
            except (RuntimeError, zipfile.BadZipFile) as exc:
                errors.append({'file': entry.filename, 'error': type(exc).__name__})
                continue
            count += 1
            total += len(data)
            for block in PEM.finditer(data):
                label = block[1].decode()
                if 'KEY' not in label and 'CERTIFICATE' not in label:
                    continue
                blob = block[0]
                cache_key = hashlib.sha256(blob).digest()
                if cache_key not in parsed_cache:
                    try:
                        if 'PRIVATE KEY' in label:
                            pub = serialization.load_pem_private_key(blob, None).public_key()
                            kind = 'private_key'
                        elif 'PUBLIC KEY' in label:
                            pub = serialization.load_pem_public_key(blob)
                            kind = 'public_key'
                        else:
                            pub = x509.load_pem_x509_certificate(blob).public_key()
                            kind = 'certificate'
                        der = public_bytes(pub)
                        parsed_cache[cache_key] = {'kind': kind,
                            'spki_sha256': hashlib.sha256(der).hexdigest(),
                            'matches': [h for h,(t,_) in targets.items() if t == der]}
                    except (ValueError, TypeError):
                        parsed_cache[cache_key] = {'kind': 'unparsed_pem', 'label': label}
                inventory.append({'file': entry.filename, **parsed_cache[cache_key]})
            # Raw binaries/DER and common text encodings of RSA moduli.
            lower = data.lower()
            byte_tokens = b''
            if suffix in {'.h', '.c', '.cpp', '.inc', '.txt', '.ini', '.cfg', '.py'}:
                byte_tokens = b''.join(re.findall(rb'0[xX]([0-9a-fA-F]{2})(?![0-9a-fA-F])', data)).lower()
            for h, (_, modulus) in targets.items():
                forms = []
                if modulus in data:
                    forms.append('raw_big_endian_modulus')
                if modulus[::-1] in data:
                    forms.append('raw_little_endian_modulus')
                word_swap = b''.join(modulus[i:i+4][::-1] for i in range(0, len(modulus), 4))
                if word_swap in data:
                    forms.append('raw_word_byte_swapped_modulus')
                if modulus.hex().encode() in lower:
                    forms.append('contiguous_hex_modulus')
                if modulus.hex().encode() in byte_tokens:
                    forms.append('hex_byte_array_modulus')
                if forms:
                    raw_hits.append({'file': entry.filename, 'target_spki_sha256': h, 'forms': forms})
    result = {'archive': str(ARCHIVE), 'archive_bytes': ARCHIVE.stat().st_size,
              'members_scanned': count, 'uncompressed_bytes_scanned': total,
              'bitmap_members_skipped': len(skipped),
              'bitmap_bytes_skipped': sum(x['bytes'] for x in skipped),
              'nested_archives_not_recursed': nested,
              'key_and_certificate_inventory': inventory,
              'matching_modulus_locations': raw_hits, 'read_errors': errors}
    (ROOT/'verification/bootloader_keys.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({**{k: v for k,v in result.items() if k not in ['key_and_certificate_inventory', 'nested_archives_not_recursed']},
                      'pem_objects': len(inventory),
                      'unique_public_keys': sorted({x['spki_sha256'] for x in inventory if 'spki_sha256' in x}),
                      'matching_pem_objects': [x for x in inventory if x.get('matches')],
                      'unparsed_pem': [x for x in inventory if x['kind'] == 'unparsed_pem']}, indent=2))


if __name__ == '__main__':
    main()
