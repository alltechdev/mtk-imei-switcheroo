#!/usr/bin/env python3
"""Patch the exact V13.0.10.0.SCUMIXM modem image or extracted ROM.

Standalone Python; no external packages. Edits a copy, never flashes or signs.
Use --input and --output for explicit paths; --raw-rom selects extracted ROM.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROM_SHA256 = '089bbfffac450e556babfdbc9b50b17a5b3988413099366b97a7b8c303216390'
ROM_SIZE = 22801380
OFFSET = 0x0130D700
ORIGINAL = bytes.fromhex('f0 64 20 6e 0c 04')
PATCH = bytes.fromhex('00 6a a0 e8 00 65')  # li v0,0; jrc ra; nop
IMAGE_NAME = 'md1img_V13.0.10.0.SCUMIXM'
IMAGE_SHA256 = '8da5be62a4b3ab760348b3ec96af11bf12e5bd0eb9dea10e6efee8a4378ba361'
IMAGE_SIZE = 57389056


def patched_rom(source):
    if len(source) != ROM_SIZE:
        raise ValueError(f'Wrong ROM size: {len(source)}; expected {ROM_SIZE}')
    digest = hashlib.sha256(source).hexdigest()
    if digest != ROM_SHA256:
        raise ValueError(f'Unrecognized input SHA-256: {digest}')
    if source[OFFSET:OFFSET+6] != ORIGINAL:
        raise ValueError('Original entry bytes do not match')
    result = bytearray(source)
    result[OFFSET:OFFSET+6] = PATCH
    return bytes(result)


def patched_image(source):
    if len(source) != IMAGE_SIZE:
        raise ValueError(f'Wrong container size: {len(source)}; expected {IMAGE_SIZE}')
    if hashlib.sha256(source).hexdigest() != IMAGE_SHA256:
        raise ValueError('Unrecognized container SHA-256')
    # Validate the embedded payload independently as well as the container.
    replacement = patched_rom(source[0x200:0x200+ROM_SIZE])
    result = bytearray(source)
    result[0x200:0x200+ROM_SIZE] = replacement
    return bytes(result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--raw-rom', action='store_true', help='Patch only the extracted ROM instead of the complete image')
    parser.add_argument('--input', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    if args.input is None:
        args.input = Path('1_md1rom') if args.raw_rom else Path('md1img.img')
    if args.output is None:
        name = '1_md1rom.return_zero.patched' if args.raw_rom else IMAGE_NAME+'.return_zero.img'
        args.output = Path('patched_v13')/name
    if args.input.resolve() == args.output.resolve():
        parser.error('Output must be a separate file')
    try:
        source = args.input.read_bytes()
        result = patched_rom(source) if args.raw_rom else patched_image(source)
        if not args.dry_run:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            # Exclusive creation also rejects an existing file or symlink.
            with args.output.open('xb') as stream:
                stream.write(result)
        print(json.dumps({
            'input': str(args.input), 'output': str(args.output),
            'format': 'raw ROM' if args.raw_rom else 'complete md1img container',
            'dry_run': args.dry_run, 'rom_offset': hex(OFFSET),
            'container_offset': hex(OFFSET+0x200),
            'runtime_address': hex(OFFSET+0x90000000),
            'original_bytes': ORIGINAL.hex(' '), 'patch_bytes': PATCH.hex(' '),
            'source_sha256': ROM_SHA256 if args.raw_rom else IMAGE_SHA256,
            'patched_sha256': hashlib.sha256(result).hexdigest(),
            'size': len(result),
        }, indent=2))
    except (OSError, ValueError) as error:
        parser.exit(1, f'{error}\n')


if __name__ == '__main__':
    main()
