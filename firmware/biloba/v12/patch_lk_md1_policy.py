#!/usr/bin/env python3
"""Patch only the unlocked/SBC md1img verification policy in the known LK."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ORIGINAL_SHA256 = 'cef141e957d7300ab936b030de0aad2999b2a947ff502e4b455480d93f487028'
ENTRY = 0x12225C
OFFSET = ENTRY + 23
BASE = 0x4C3FFE00


def prepare(data):
    if hashlib.sha256(data).hexdigest() != ORIGINAL_SHA256:
        raise ValueError('Input is not the audited original LK dump')
    name_offset = struct.unpack_from('<I', data, ENTRY + 4)[0] - BASE
    if data[name_offset:name_offset+7] != b'md1img\0':
        raise ValueError('Policy entry is not md1img')
    if data[ENTRY+20:ENTRY+24] != bytes.fromhex('01 00 03 02'):
        raise ValueError('Unexpected original policy')
    patched = bytearray(data)
    patched[OFFSET] &= ~2
    patched = bytes(patched)
    differences = [i for i, (a, b) in enumerate(zip(data, patched)) if a != b]
    if len(patched) != len(data) or differences != [OFFSET]:
        raise ValueError('Unexpected differences')
    states = ['sbc_disabled_locked', 'sbc_disabled_unlocked',
              'sbc_enabled_locked', 'sbc_enabled_unlocked']
    truth_table = {state: {'original_policy': data[ENTRY+20+i],
                           'patched_policy': patched[ENTRY+20+i],
                           'original_verify': (data[ENTRY+20+i] >> 1) & 1,
                           'patched_verify': (patched[ENTRY+20+i] >> 1) & 1}
                   for i, state in enumerate(states)}
    report = {
        'original_sha256': ORIGINAL_SHA256,
        'patched_sha256': hashlib.sha256(patched).hexdigest(),
        'size_bytes': len(data), 'changed_bytes': 1,
        'file_offset': hex(OFFSET), 'runtime_address': hex(OFFSET + BASE),
        'before_hex': '02', 'after_hex': '00',
        'policy_before': '01 00 03 02', 'policy_after': '01 00 03 00',
        'verification_truth_table': truth_table,
        'all_other_bytes_identical': True,
        'boot_tested': False, 'signatures_regenerated': False,
        'requires_preloader_to_accept_unlocked_state': True,
        'modem_hardware_authentication_bypassed': False,
    }
    return patched, report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=Path('lk.img'))
    parser.add_argument('--output', type=Path, default=Path('patched_v12/lk.md1img_unlocked_noverify.bin'))
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    if args.input.resolve() == args.output.resolve():
        parser.error('In-place patching is forbidden')
    patched, report = prepare(args.input.read_bytes())
    report.update(input=str(args.input), output=str(args.output))
    if not args.dry_run:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        if args.output.with_suffix(args.output.suffix+'.json').exists():
            parser.error('Output JSON already exists')
        with args.output.open('xb') as stream:
            stream.write(patched)
        if args.output.read_bytes() != patched:
            raise RuntimeError('Output readback differs')
        manifest = args.output.with_suffix(args.output.suffix+'.json')
        with manifest.open('x') as stream:
            stream.write(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
