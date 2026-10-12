"""Execute actual LK/preloader selectors and LK verifier in qemu-arm-static.

Only state providers, logging, timer and the authentication endpoint are stubbed.
No crypto, hardware secure boot, or full device boot is emulated.
"""
import argparse
import hashlib
import json
import struct
import subprocess
from pathlib import Path

ROOT = Path.cwd()
OUT = ROOT/'verification'


def mov32(reg, value):
    lo, hi = value & 65535, value >> 16
    return [0xe3000000 | (lo & 0xf000) << 4 | reg << 12 | lo & 0xfff,
            0xe3400000 | (hi & 0xf000) << 4 | reg << 12 | hi & 0xfff]


def elf(data, delta, words):
    page = delta & ~4095
    payload = bytes(delta-page) + data
    image = bytearray(0x1000) + payload
    ident = b'\x7fELF\x01\x01\x01' + bytes(9)
    image[:52] = struct.pack('<16sHHIIIIIHHHHHH', ident, 2, 40, 1,
                            0x10100, 52, 0, 0x05000000, 52, 32, 2, 40, 0, 0)
    for i, (off, va, size) in enumerate([(0, 0x10000, 0x1000), (0x1000, page, len(payload))]):
        image[52+32*i:84+32*i] = struct.pack('<8I', 1, off, va, va, size, size, 7, 4096)
    image[0x100:0x100+len(words)*4] = struct.pack('<'+'I'*len(words), *words)
    return image


def run(name, original, delta, selector, index, sbc, lock, expected, verify=False):
    data = bytearray(original)
    def stub(address, raw):
        offset = address-delta
        data[offset:offset+len(raw)] = raw
    state = lambda value: bytes([value, 0x21, 1, 0x60, 0, 0x20, 0x70, 0x47])
    if delta == 0x4c3ffe00:
        stub(0x4c46c7f0, state(sbc))
        stub(0x4c425b24, state(lock))
        stub(0x4c43f57c, bytes.fromhex('00 20 70 47'))
        stub(0x4c45de80, bytes.fromhex('00 20 70 47'))
        # Authentication sentinel: exit(42) proves the actual call was reached.
        stub(0x4c46cca8, bytes.fromhex('2a 20 01 27 00 df'))
        struct.pack_into('<II', data, 0x207228, 0, 0)  # LTE/C2K flags clear
    else:
        stub(0x235980, state(sbc))
        stub(0x235998, state(lock))
        stub(0x22d964, bytes.fromhex('00 20 70 47'))
    words = mov32(0, index) + mov32(12, selector | 1) + [0xe12fff3c]
    if verify:
        words += mov32(4, delta+0x207224) + [0xe5840000]  # store actual selected flag
        words += mov32(0, delta+0x8064c) + mov32(1, delta+0x111a70)
        words += mov32(2, 0) + mov32(3, 0)
        words += mov32(12, delta+0x55df8+1) + [0xe12fff3c]
        words += mov32(0, 0)
    # Exit with actual getter result, or 0 when verifier returned without auth.
    words += [0xe3a07001, 0xef000000]
    path = OUT/(name+'.elf')
    path.write_bytes(elf(data, delta, words))
    path.chmod(0o700)
    result = subprocess.run(['qemu-arm-static', str(path)], capture_output=True, text=True, timeout=10)
    row = dict(case=name, secure_boot=sbc, lock_state=lock, expected_exit=expected,
               actual_exit=result.returncode, stderr=result.stderr,
               actual_image_verifier_executed=verify)
    if result.returncode != expected:
        raise AssertionError(row)
    return row


def main():
    lk = (ROOT/'inputs/lk.img').read_bytes()
    patched = (ROOT/'patched/lk.img').read_bytes()
    pl = (ROOT/'inputs/preloader.img').read_bytes()
    for data, digest in [(lk, 'cef141e957d7300ab936b030de0aad2999b2a947ff502e4b455480d93f487028'),
                         (patched, 'b3fab4a083cd4955b7c8a8a83bc7b2d5f562d66ef6542c449952369c2f36843f'),
                         (pl, '165cb58913f342e2b445d35e8e3e526ecd674b622b410e23d83a780ee64f1c99')]:
        assert hashlib.sha256(data).hexdigest() == digest
    rows = []
    for sbc in (0, 1):
        for lock in (3, 4):
            tag = f'sbc{sbc}_lock{lock}'
            for name, data, expected in [('original', lk, sbc), ('patched', patched, int(sbc==1 and lock==4))]:
                rows.append(run(f'lk_{name}_{tag}', data, 0x4c3ffe00, 0x4c417920, 12, sbc, lock, expected))
            rows.append(run(f'preloader_{tag}', pl, 0x200710, 0x22fee4, 2, sbc, lock, int(sbc==1 and lock==4)))
    rows.append(run('lk_original_reaches_auth', lk, 0x4c3ffe00, 0x4c417920, 12, 1, 3, 42, True))
    rows.append(run('lk_patched_skips_auth', patched, 0x4c3ffe00, 0x4c417920, 12, 1, 3, 0, True))
    rows.append(run('lk_patched_locked_reaches_auth', patched, 0x4c3ffe00, 0x4c417920, 12, 1, 4, 42, True))
    (OUT/'lk_execution_results.json').write_text(json.dumps(rows, indent=2)+'\n')
    print(json.dumps(rows, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work', type=Path, required=True)
    ROOT = parser.parse_args().work.resolve()
    OUT = ROOT/'verification'
    OUT.mkdir(parents=True, exist_ok=True)
    main()
