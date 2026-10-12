"""Run the original caller's skip path with the patched gate under QEMU.

This is an isolated Linux user-mode harness, not modem emulation. It copies
the original caller unchanged and substitutes allocator/free/logger stubs.
Code uses the low address alias so JAL targets remain valid in user mode.
No device, container signature verification, or real modem APIs are involved.
"""
import argparse
import hashlib
import json
import struct
import subprocess
from pathlib import Path
PATCH = bytes.fromhex('00 6a a0 e8 00 65')
ROM_SHA256 = '089bbfffac450e556babfdbc9b50b17a5b3988413099366b97a7b8c303216390'

ROOT = Path.cwd()


def build(expected_result):
    rom = (ROOT/'members/1_md1rom').read_bytes()
    assert hashlib.sha256(rom).hexdigest() == ROM_SHA256
    image = bytearray(0x4000)
    ident = b'\x7fELF\x01\x01\x01' + bytes(9)
    image[:52] = struct.pack('<16sHHIIIIIHHHHHH', ident, 2, 8, 1, 0x10100,
                            52, 0, 0x74001000, 52, 32, 4, 40, 0, 0)
    for n, (fileoff, vaddr) in enumerate([(0, 0x10000), (0x1000, 0x298000),
                                        (0x2000, 0x950000), (0x3000, 0x130d000)]):
        image[52+n*32:84+n*32] = struct.pack('<IIIIIIII', 1, fileoff, vaddr,
                                             vaddr, 0x1000, 0x1000, 7, 0x1000)
    words = [
        0x3c190130,       # lui t9,0x130
        0x3739d905,       # ori t9,t9,0xd905: original MIPS16 caller entry
        0x03a08021,       # move s0,sp: caller must preserve this saved register
        0x0320f809,       # jalr t9
        0x00000000,       # delay slot
        0x24080000 | expected_result,  # li t0,expected
        0x14480007,       # bne v0,t0,failure
        0x00000000,
        0x17b00005,       # bne sp,s0,failure
        0x00000000,
        0x24040000,       # exit(0)
        0x24020fa1,
        0x0000000c,
        0x00000000,
        0x24040063,       # failure: exit(99)
        0x24020fa1,
        0x0000000c,
    ]
    image[0x100:0x100+len(words)*4] = struct.pack('<'+'I'*len(words), *words)
    image[0x1af0:0x1af4] = bytes.fromhex('00 6a a0 e8')  # logging returns 0
    image[0x2674:0x2678] = bytes.fromhex('01 6a a0 e8')  # allocation succeeds
    image[0x2680:0x2684] = bytes.fromhex('00 6a a0 e8')  # free stub
    image[0x3700:0x3706] = PATCH
    # Include caller, padding, and literal pool. External strings aren't read
    # by these stubs, so their original high-alias pointers are retained.
    image[0x3904:0x3a50] = rom[0x130d904:0x130da50]
    return image


def main():
    dest = ROOT/'verification'
    results = []
    for name, expected, exitcode in [('caller_skip_success', 1, 0),
                                      ('caller_wrong_expectation', 0, 99)]:
        elf = dest/(name+'.elf')
        elf.write_bytes(build(expected))
        elf.chmod(0o700)
        result = subprocess.run(['qemu-mipsel-static', '-cpu', '24Kc', str(elf)],
                                capture_output=True, text=True, timeout=10)
        row = {'case': name, 'expected_caller_result': expected,
               'expected_exit': exitcode, 'actual_exit': result.returncode,
               'stderr': result.stderr}
        results.append(row)
        assert result.returncode == exitcode, row
    (dest/'caller_results.json').write_text(json.dumps(results, indent=2)+'\n')
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work', type=Path, required=True)
    ROOT = parser.parse_args().work.resolve()
    OUT = ROOT/'verification'
    OUT.mkdir(parents=True, exist_ok=True)
    main()
