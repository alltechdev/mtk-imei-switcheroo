"""Read keys.zip in memory and audit public-key compatibility; never sign.

Only public fingerprints, filenames, and verification results are written.
MediaTek cert1/cert2 contain custom ASN.1 fields, so they are not loaded as
standard X.509 certificates. Preserve the original DER signed sequence.
"""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding



def digest(data):
    return hashlib.sha256(data).hexdigest()


def public_bytes(pub):
    return pub.public_bytes(serialization.Encoding.DER,
                            serialization.PublicFormat.SubjectPublicKeyInfo)


def tlv(data, offset):
    if offset + 2 > len(data):
        raise ValueError('Truncated DER tag')
    tag, length = data[offset:offset+2]
    start = offset + 2
    if length & 128:
        count = length & 127
        if not count or count > 4 or start + count > len(data):
            raise ValueError('Invalid DER length')
        length = int.from_bytes(data[start:start+count], 'big')
        start += count
    end = start + length
    if end > len(data):
        raise ValueError('Truncated DER value')
    return tag, start, end


def children(data, start, end):
    while start < end:
        tag, content, next_offset = tlv(data, start)
        if next_offset > end:
            raise ValueError('Child exceeds parent')
        yield start, tag, content, next_offset
        start = next_offset


def verifies(pub, signature, signed):
    try:
        pub.verify(signature, signed,
                   padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=32),
                   hashes.SHA256())
        return True
    except InvalidSignature:
        return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work', type=Path, required=True)
    parser.add_argument('--keys', type=Path, required=True)
    args = parser.parse_args()
    ROOT = args.work.resolve()
    archive = args.keys
    groups = {}
    with zipfile.ZipFile(archive) as z:
        for name in z.namelist():
            if not name.endswith('.pem'):
                continue
            key = serialization.load_pem_private_key(z.read(name), password=None)
            pub = key.public_key()
            encoded = public_bytes(pub)
            fingerprint = digest(encoded)
            group = groups.setdefault(fingerprint, {'pub': pub, 'der': encoded,
                                                    'key_bits': pub.key_size, 'files': []})
            group['files'].append(name)
    manifest = json.loads((ROOT/'members/manifest.json').read_text())
    image = (ROOT/'inputs/md1img.img').read_bytes()
    if digest(image) not in ['1dd3043e889356bd5edb9343a96fe3122dc0fae7245047e815f695902a6002ab', '4077b7aa2b0d7eb1f0c51cde274fb2053e90e66e64134765410a74d1d01442fc']:
        raise ValueError('Original image hash mismatch')
    results = []
    for member in manifest:
        if member['name'] not in ['cert1', 'cert2']:
            continue
        offset = member['container_header_offset'] + int(member['header']['data_offset'], 0)
        data = image[offset:offset+member['header']['data_size']]
        if digest(data) != member['sha256']:
            raise ValueError('Certificate does not match extraction manifest')
        _, start, end = tlv(data, 0)
        outer = list(children(data, start, end))
        if len(outer) != 3 or outer[2][1] != 3:
            raise ValueError('Unexpected certificate layout')
        signed = data[outer[0][0]:outer[0][3]]
        if data[outer[2][2]] != 0:
            raise ValueError('Unexpected signature BIT STRING padding')
        signature = data[outer[2][2]+1:outer[2][3]]
        cert_keys = []
        for at, tag, _, stop in children(data, outer[0][2], outer[0][3]):
            if tag != 48:
                continue
            try:
                pub = serialization.load_der_public_key(data[at:stop])
            except ValueError:
                continue
            encoded = public_bytes(pub)
            matches = [g for g in groups.values() if g['der'] == encoded]
            cert_keys.append({'certificate_offset': at, 'key_bits': pub.key_size,
                              'spki_sha256': digest(encoded),
                              'matching_archive_files': [f for g in matches for f in g['files']],
                              'verifies_certificate_signature': verifies(pub, signature, signed)})
        verified_archive = [h for h, g in groups.items() if verifies(g['pub'], signature, signed)]
        results.append({'name': member['name'], 'container_payload_offset': hex(offset),
                        'public_keys': cert_keys, 'archive_signature_verifiers': verified_archive})
    # For this exact image, cert2 stores SHA-256(payload with 16-byte alignment)
    # and SHA-256(the 512-byte member header) in these two BIT STRING fields.
    cert = (ROOT/'members/3_cert2').read_bytes()
    stored_payload = cert[499:531].hex()
    stored_header = cert[555:587].hex()
    patched = (ROOT/'patched/md1img.img').read_bytes()
    payload_end = manifest[1]['container_header_offset']
    coverage = {'stored_payload_sha256': stored_payload,
                'original_payload_with_alignment_sha256': digest(image[512:payload_end]),
                'patched_payload_with_alignment_sha256': digest(patched[512:payload_end]),
                'stored_header_sha256': stored_header,
                'original_header_sha256': digest(image[:512]),
                'patched_header_sha256': digest(patched[:512]),
                'payload_range_in_container': [hex(512), hex(payload_end)]}
    assert stored_payload == coverage['original_payload_with_alignment_sha256']
    assert stored_payload != coverage['patched_payload_with_alignment_sha256']
    assert stored_header == coverage['original_header_sha256'] == coverage['patched_header_sha256']
    report = {'archive_sha256': digest(archive.read_bytes()),
              'private_key_files': sum(len(g['files']) for g in groups.values()),
              'unique_public_keys': len(groups),
              'archive_groups': {h: {'key_bits': g['key_bits'], 'files': g['files']} for h,g in groups.items()},
              'certificates': results, 'rom_digest_coverage': coverage}
    dest = ROOT/'verification/signing_keys.json'
    dest.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({'private_key_files': report['private_key_files'],
                      'unique_public_keys': len(groups),
                      'certificate_key_matches': sum(len(k['matching_archive_files']) for r in results for k in r['public_keys']),
                      'archive_signature_verifiers': sum(len(r['archive_signature_verifiers']) for r in results),
                      'rom_digest_coverage': coverage}, indent=2))


if __name__ == '__main__':
    main()
