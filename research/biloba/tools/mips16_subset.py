"""Auditable MIPS16 decoder for the instructions in the identified gate.

Not a general disassembler. Unsupported encodings raise ValueError.
Encoding reference: Ghidra's MIPS/data/languages/mips16.sinc.
Offsets are extracted-ROM offsets; displayed VAs use the observed 0x90000000 alias.
"""
import argparse
import struct
from pathlib import Path

BASE = 0x90000000
REG = ['s0', 's1', 'v0', 'v1', 'a0', 'a1', 'a2', 'a3']
REG32 = ['zero', 'at', 'v0', 'v1', 'a0', 'a1', 'a2', 'a3'] + [f't{i}' for i in range(8)] + [f's{i}' for i in range(8)] + ['t8', 't9', 'k0', 'k1', 'gp', 'sp', 's8', 'ra']


def signed(n, bits):
    return (n ^ (1 << (bits - 1))) - (1 << (bits - 1))


def decode(data, off, delay_start=None):
    h = struct.unpack_from('<H', data, off)[0]
    size = 2
    ext = None
    if h >> 11 == 30:
        ext = h & 0x7ff
        h = struct.unpack_from('<H', data, off + 2)[0]
        size = 4
    op = h >> 11
    x, y, z = REG[(h >> 8) & 7], REG[(h >> 5) & 7], REG[(h >> 2) & 7]
    imm = ((ext & 31) << 11 | (ext & 0x7e0) | (h & 31)) if ext is not None else h & 255
    simm = signed(imm, 16 if ext is not None else 8)
    target = None
    pool = None
    delayed = False
    text = None
    if op == 3 and ext is None:
        lo = struct.unpack_from('<H', data, off + 2)[0]
        target = ((BASE + off + 4) & 0xf0000000) | (((h & 31) << 21 | ((h >> 5) & 31) << 16 | lo) << 2)
        text = f"{'jalx' if h & 0x400 else 'jal'} 0x{target:08x}"
        size, delayed = 4, True
    elif op in [0, 1]:
        v = simm if ext is not None else imm * 4
        text = f"addiu {x}, {'sp' if op == 0 else 'pc'}, {v}"
    elif op in [2, 4, 5] or op == 12 and ((h >> 8) & 7) in [0, 1]:
        delta = simm if ext is not None or op != 2 else signed(h & 0x7ff, 11)
        target = BASE + off + size + 2 * delta
        name = {2: 'b', 4: 'beqz', 5: 'bnez'}.get(op, 'btnez' if h & 0x100 else 'bteqz')
        text = f'{name} ' + (f'{x}, ' if op in [4, 5] else '') + f'0x{target:08x}'
    elif op == 8 and not h & 16:
        v = signed(((ext & 15) << 11) | ((ext & 0x7f0)) | (h & 15), 15) if ext is not None else signed(h & 15, 4)
        text = f'addiu {y}, {x}, {v}'
    elif op == 9:
        text = f'addiu {x}, {simm}'
    elif op in [10, 11]:
        text = f"{'slti' if op == 10 else 'sltiu'} {x}, {simm if ext is not None else imm}"
    elif op == 12:
        sub = (h >> 8) & 7
        if sub == 4 and ext is None:
            regs = [r for mask, r in [(64, 'ra'), (32, 's0'), (16, 's1')] if h & mask]
            text = f"{'save' if h & 128 else 'restore'} {(h & 15) * 8 or 128}, " + ', '.join(regs)
        elif sub == 5 and ext is None:
            dest = ((h >> 5) & 7) | (h & 24)
            text = 'nop' if h == 0x6500 else f'move {REG32[dest]}, {REG[h & 7]}'
        elif sub == 7 and ext is None:
            text = f'move {y}, {REG32[h & 31]}'
        elif sub == 3:
            text = f'addiu sp, {simm if ext is not None else simm * 8}'
    elif op == 13:
        name = {0: 'li', 1: 'lui', 3: 'andi'}.get((h >> 5) & 7) if ext is not None else 'li'
        if name is None:
            raise ValueError(f'Unsupported extended immediate at {off:#x}')
        text = f'{name} {x}, 0x{imm:x}'
    elif op == 14:
        text = f'cmpi {x}, 0x{imm:x}'
    elif op in [16, 17, 19, 20, 21, 24, 25, 27]:
        name, shift = {16: ('lb', 0), 17: ('lh', 1), 19: ('lw', 2), 20: ('lbu', 0), 21: ('lhu', 1), 24: ('sb', 0), 25: ('sh', 1), 27: ('sw', 2)}[op]
        v = simm if ext is not None else (h & 31) << shift
        text = f'{name} {y}, {v}({x})'
    elif op in [18, 26]:
        v = simm if ext is not None else imm * 4
        text = f"{'lw' if op == 18 else 'sw'} {x}, {v}(sp)"
    elif op == 22:
        pc = off if delay_start is None else delay_start
        pool = ((off + simm) if ext is not None else (pc + imm * 4)) & ~3
        val = struct.unpack_from('<I', data, pool)[0]
        text = f'lw {x}, [0x{BASE+pool:08x}] ; =0x{val:08x}'
        p = val - BASE
        if 0 <= p < len(data):
            s = data[p:p+160].split(b'\0')[0]
            if s and all(32 <= b < 127 for b in s):
                text += ' ' + repr(s.decode())
    elif op == 28 and ext is None and h & 3 in [1, 3]:
        text = f"{'addu' if h & 3 == 1 else 'subu'} {z}, {x}, {y}"
    elif op == 29 and ext is None:
        sub = h & 31
        if sub == 0:
            name = 'jalr' if h & 64 else 'jr'
            if h & 128:
                name += 'c'
            delayed = not bool(h & 128)
            text = f"{name} {'ra' if h & 32 else x}"
        elif sub in [2, 3, 10, 11, 12, 13, 14, 15]:
            name = {2: 'slt', 3: 'sltu', 10: 'cmp', 11: 'neg', 12: 'and', 13: 'or', 14: 'xor', 15: 'not'}[sub]
            text = f'{name} {x}, {y}'
        elif sub == 17 and ((h >> 5) & 7) == 0:
            text = f'zeb {x}'
        elif sub == 5:
            text = f'break {(h >> 5) & 63}'
    if text is None:
        raise ValueError(f'Unsupported encoding at ROM 0x{off:x}: {data[off:off+size].hex()}')
    return {'offset': off, 'size': size, 'text': text, 'target': target, 'pool': pool, 'delayed': delayed}


def disassemble(data, start, end):
    out = []
    off = start
    delay = None
    while off < end:
        ins = decode(data, off, delay)
        out.append(ins)
        delay = off if ins['delayed'] else None
        off += ins['size']
    if off != end:
        raise ValueError('End is not an instruction boundary')
    return out


def format_listing(data, insns):
    return '\n'.join(f"{i['offset']:08x}  {BASE+i['offset']:08x}  {data[i['offset']:i['offset']+i['size']].hex(' '):11}  {i['text']}" for i in insns)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('start', type=lambda s: int(s, 0))
    parser.add_argument('end', type=lambda s: int(s, 0))
    parser.add_argument('--rom', type=Path, required=True)
    args = parser.parse_args()
    data = args.rom.read_bytes()
    print(format_listing(data, disassemble(data, args.start, args.end)))
