#!/usr/bin/env python3
"""Build and verify one exact biloba firmware pair, entirely offline."""
import argparse
import hashlib
import importlib.metadata
import importlib.util
import json
import platform
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
RESEARCH = REPO/'research/biloba'
TOOLS = RESEARCH/'tools'


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2)+'\n')


def extract(image, dest):
    """Preserve raw MTK members; do not mount filesystems or repack firmware."""
    data = image.read_bytes()
    offset, result = 0, []
    while True:
        magic, size, raw_name, *fields = struct.unpack_from('<II32s10I', data, offset)
        base, mode, magic2, data_offset, version, kind, last, align, extended, addr_extended = fields
        name = raw_name.split(b'\0', 1)[0].decode('ascii')
        if (magic != 0x58881688 or magic2 != 0x58891689 or data_offset != 512
                or align != 16 or extended or not re.fullmatch(r'[A-Za-z0-9_]+', name)):
            raise ValueError(f'Unexpected member header at {offset:#x}')
        start, end = offset+data_offset, offset+data_offset+size
        if end > len(data):
            raise ValueError('Truncated member')
        payload = data[start:end]
        (dest/f'{len(result)+1}_{name}').write_bytes(payload)
        result.append(dict(name=name, container_header_offset=offset,
                           header=dict(data_offset=hex(data_offset), data_size=size),
                           sha256=hashlib.sha256(payload).hexdigest()))
        if last == 1:
            break
        offset = (end+align-1)//align*align
    if len(result) != 21:
        raise ValueError('Expected 21 modem members')
    save(dest/'manifest.json', result)
    return result


def audit(work, profile, members):
    # Import only repository-owned analysis helpers; no archive code is executed.
    sys.path.insert(0, str(TOOLS))
    import mips16_subset as mips
    import check_signing_keys as certs
    from cryptography.hazmat.primitives import serialization
    rom = (work/'members/1_md1rom').read_bytes()
    counts = {}
    for name in ['gate', 'caller']:
        start, end = profile[name+'_range']
        instructions = mips.disassemble(rom, start, end)
        boundaries = {ins['offset'] for ins in instructions}
        for ins in instructions:
            target = ins['target']
            if target is not None and start <= target-mips.BASE < end:
                if target-mips.BASE not in boundaries:
                    raise ValueError('Branch target is not an instruction boundary')
        (work/'disassembly'/f'{name}.asm').write_text(mips.format_listing(rom,instructions)+'\n')
        counts[name] = len(instructions)
    lk = (work/'inputs/lk.img').read_bytes()
    entry = profile['lk_policy_entry']
    name_offset = struct.unpack_from('<I',lk,entry+4)[0]-0x4c3ffe00
    if lk[name_offset:name_offset+7] != b'md1img\0' or lk[entry+20:entry+24] != bytes.fromhex('01 00 03 02'):
        raise ValueError('Unexpected LK entry')
    pl = (work/'inputs/preloader.img').read_bytes()
    off = profile['preloader_lk_policy_offset']
    if pl[off:off+4] != bytes.fromhex('01 00 03 00'):
        raise ValueError('Unexpected preloader policy')
    signatures = []
    for index, member in enumerate(members,1):
        if member['name'] not in ('cert1','cert2'):
            continue
        data = (work/'members'/f'{index}_{member["name"]}').read_bytes()
        _, start, end = certs.tlv(data,0)
        children = list(certs.children(data,start,end))
        signed = data[children[0][0]:children[0][3]]
        signature = data[children[2][2]+1:children[2][3]]
        _, _, end = certs.tlv(data,181)
        pub = serialization.load_der_public_key(data[181:end])
        if not certs.verifies(pub,signature,signed):
            raise ValueError('Original certificate signature did not verify')
        signatures.append(dict(member=index, signature_valid=True))
    end = members[1]['container_header_offset']
    original = (work/'inputs/md1img.img').read_bytes()
    patched = (work/'patched/md1img.img').read_bytes()
    stored = (work/'members/3_cert2').read_bytes()[499:531].hex()
    actual = hashlib.sha256(original[512:end]).hexdigest()
    changed = hashlib.sha256(patched[512:end]).hexdigest()
    if stored != actual or stored == changed:
        raise ValueError('Unexpected signed digest coverage')
    save(work/'verification/static_audit.json', dict(instruction_counts=counts,
         branch_boundaries_valid=True, certificates=signatures,
         original_rom_digest=actual, patched_rom_digest=changed,
         lk_policy='01 00 03 02', preloader_lk_policy='01 00 03 00'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', choices=['v12','v14'], required=True)
    parser.add_argument('--modem', type=Path, required=True)
    parser.add_argument('--lk', type=Path, required=True)
    parser.add_argument('--preloader', type=Path, required=True, help='Read-only verification input; never patched')
    parser.add_argument('--output', type=Path, required=True, help='New run directory')
    parser.add_argument('--keys', type=Path, help='Optional private-key ZIP compatibility audit')
    parser.add_argument('--bootloader-archive', type=Path, help='Optional source ZIP key scan')
    parser.add_argument('--seccfg', type=Path, help='Optional saved-state software digest check')
    parser.add_argument('--check', action='store_true', help='Preflight only; writes nothing')
    args = parser.parse_args()
    if sys.flags.optimize:
        parser.error('Run without -O: verification harnesses use assertions')
    profile_path = HERE/args.version/'profile.json'
    profile = json.loads(profile_path.read_text())
    versions = dict(python=platform.python_version())
    for module in ['capstone','cryptography']:
        if importlib.util.find_spec(module) is None:
            parser.error(f'Missing {module}; see firmware/biloba/requirements.txt')
        versions[module] = importlib.metadata.version(module)
    for command in ['qemu-arm-static','qemu-mipsel-static']:
        executable = shutil.which(command)
        if executable is None:
            parser.error(f'Missing {command}; install qemu-user-static')
        versions[command] = subprocess.check_output([executable,'--version'],text=True).splitlines()[0]
    inputs = {'md1img.img':args.modem.resolve(), 'lk.img':args.lk.resolve(), 'preloader.img':args.preloader.resolve()}
    fingerprints = {}
    for name,path in inputs.items():
        if not path.is_file() or sha(path)!=profile['inputs'][name]:
            parser.error(f'Unsupported or missing {name} for {args.version}: {path}')
        fingerprints[name] = dict(sha256=sha(path), bytes=path.stat().st_size)
    optional = {name:path.resolve() for name,path in [('keys',args.keys),('bootloader_archive',args.bootloader_archive),('seccfg',args.seccfg)] if path is not None}
    for name,path in optional.items():
        if not path.is_file():
            parser.error(f'Missing {name}: {path}')
        fingerprints[name] = dict(sha256=sha(path), bytes=path.stat().st_size)
    out = args.output.resolve()
    if out.exists():
        parser.error('Output already exists; choose a fresh directory')
    if args.check:
        print(json.dumps(dict(status='preflight_passed',inputs=fingerprints,versions=versions),indent=2))
        return
    out.mkdir(parents=True)
    for name in ['inputs','members','patched','verification','disassembly','logs']:
        (out/name).mkdir()
    report = dict(status='running',version=args.version,inputs=fingerprints,versions=versions,
                  steps=[],optional_audits=list(optional),hardware_boot_tested=False,device_accessed=False,
                  profile_sha256=sha(profile_path),script_sha256={})
    def run(script,*arguments):
        relative = str(script.relative_to(REPO))
        report['script_sha256'][relative] = sha(script)
        print('Running',relative,flush=True)
        result = subprocess.run([sys.executable,str(script),*map(str,arguments)],cwd=out,
                                capture_output=True,text=True,timeout=300)
        log = f'{len(report["steps"])+1:02d}_{script.stem}.txt'
        (out/'logs'/log).write_text(result.stdout+'\n'+result.stderr)
        report['steps'].append(dict(script=relative,exit_code=result.returncode,log='logs/'+log))
        if result.returncode:
            raise RuntimeError(f'{relative} failed; see {out/"logs"/log}')
    try:
        report['script_sha256'][str(Path(__file__).resolve().relative_to(REPO))] = sha(Path(__file__))
        for name,path in inputs.items():
            shutil.copyfile(path,out/'inputs'/name)
            if sha(out/'inputs'/name)!=fingerprints[name]['sha256']:
                raise RuntimeError('Input changed while copying')
        members = extract(out/'inputs/md1img.img',out/'members')
        for key,name in [('modem_patcher','md1img.img'),('lk_patcher','lk.img')]:
            run(HERE/args.version/profile[key],'--input',out/'inputs'/name,'--output',out/'patched'/name)
        for name,expected in profile['outputs'].items():
            if sha(out/'patched'/name)!=expected:
                raise RuntimeError(f'{name} differs from established candidate')
        audit(out,profile,members)
        run(RESEARCH/args.version/'verify_patched_caller.py','--work',out)
        run(RESEARCH/args.version/'verify_lk_execution.py','--work',out)
        if args.keys:
            run(TOOLS/'check_signing_keys.py','--work',out,'--keys',args.keys.resolve())
        if args.bootloader_archive:
            run(TOOLS/'check_bootloader_archive.py','--work',out,'--archive',args.bootloader_archive.resolve())
        if args.seccfg:
            run(TOOLS/'check_seccfg_offline.py','--input',args.seccfg.resolve(),'--output',out/'verification/seccfg_offline.json')
        for name,path in {**inputs,**optional}.items():
            if sha(path)!=fingerprints[name]['sha256']:
                raise RuntimeError('Source input changed during run')
        for script in TOOLS.glob('*.py'):
            report['script_sha256'][str(script.relative_to(REPO))] = sha(script)
        (out/'patched/SHA256SUMS').write_text(''.join(f'{h}  {name}\n' for name,h in profile['outputs'].items()))
        report.update(status='passed',outputs=profile['outputs'],source_inputs_unchanged=True)
    except Exception as error:
        report.update(status='failed',error=str(error))
        save(out/'manifest.json',report)
        raise
    save(out/'manifest.json',report)
    print(f'PASS: {args.version}; byte-identical outputs and 17 execution cases. {out}')


if __name__=='__main__':
    main()
