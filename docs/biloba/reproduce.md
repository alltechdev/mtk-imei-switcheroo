# Reproduce the biloba offline checks

Use the repository checkout and your own original firmware files. The runner
accepts only the exact [fingerprints](artifacts.md) recorded for each version.
It creates a new run directory and leaves source files unchanged. It does not
flash a phone or regenerate signatures.

## Dependencies

Linux, Python 3.11+ and the `qemu-arm-static` / `qemu-mipsel-static` executables
are required. On Debian/Ubuntu, install `qemu-user-static`. From the repository root:

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r firmware/biloba/requirements.txt
```

Standalone [patchers](patchers.md) require only Python's standard library.

## Original inputs

Keep inputs outside the checkout, or in an ignored run directory. The V12
modem is `md1img_global_V12.5.2.0.RCUMIXM.img`; its LK and preloader inputs
are the supplied `lk_a,b.bin` and `preloader.emmc.boot1,2.bin` dumps.
The V14 inputs are `firmware-update/md1img.img`, `firmware-update/lk.img`
and `firmware-update/preloader.img` extracted from the identified V14 ZIP.
The preloader is inspected only.

## Run one version

Replace the three input paths with your local originals:

```sh
python3 firmware/biloba/reproduce.py --version v12 \
  --modem /path/to/md1img_global_V12.5.2.0.RCUMIXM.img \
  --lk '/path/to/lk_a,b.bin' \
  --preloader '/path/to/preloader.emmc.boot1,2.bin' \
  --output runs/v12

python3 firmware/biloba/reproduce.py --version v14 \
  --modem /path/to/firmware-update/md1img.img \
  --lk /path/to/firmware-update/lk.img \
  --preloader /path/to/firmware-update/preloader.img \
  --output runs/v14
```

Add `--check` to validate dependencies and input hashes without writing files.
Each actual run requires a fresh output directory. Do not run Python with `-O`:
the execution harnesses use assertions.

The runner extracts the modem members, applies both patches, checks the outputs
against established hashes, disassembles the gate/caller, validates branch
boundaries and original certificate signatures, checks signed digest coverage,
and runs two MIPS caller cases plus 15 ARM policy/verifier cases.

## Results

| Run path | Contents |
| --- | --- |
| `manifest.json` | Status, fingerprints, dependency versions, script hashes and steps |
| `patched/` | Complete `md1img.img`, `lk.img`, LK report and `SHA256SUMS` |
| `verification/` | Static audit, execution results and generated test fixtures |
| `disassembly/` | Gate and caller listings |
| `logs/` | Output from each helper |
| `inputs/`, `members/` | Local input copies and extracted modem members |

A passing run reproduces the established bytes and isolated tests. V12's paired
patch was reported working by the tester; V14 has no reported boot test.
See [remaining limits](verification.md) before interpreting these results.

## Optional local audits

Append any of these flags to the same command:

```text
--keys /path/to/keys.zip
--bootloader-archive /path/to/bootloader.zip
--seccfg /path/to/seccfg.bin
```

These produce additional JSON reports without copying the supplied archives.
Key scans report compatibility; they do not sign outputs. A failed software
seccfg digest match does not establish invalid hardware-backed state.
Do not publish run directories: they contain your firmware copies and may
contain local paths and archive filenames in reports.
