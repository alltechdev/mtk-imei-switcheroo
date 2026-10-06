# Standalone biloba patchers

These scripts were supplied separately during the firmware investigation.
**They are not included in this repository checkout.** The existing
`imei_tool.py` and `live_patch.sh` modify NVRAM; they do not perform these edits.
No firmware images or private keys are included in this documentation update.

## Older tested pair

Attachments: `patch_is_enable.py` and `patch_lk_md1_policy.py`.
Use the V12 modem and exact supplied LK dump identified in [artifacts](artifacts.md).

```sh
python3 patch_is_enable.py --input original_md1img.img --output patched_md1img.img --dry-run
python3 patch_lk_md1_policy.py --input original_lk.bin --output patched_lk.bin --dry-run
```

## V14.0.4.0 pair

Attachments: `patch_is_enable_V14.0.4.0.py` and
`patch_lk_md1_policy_V14.0.4.0.py`. Extract `firmware-update/md1img.img` and
`firmware-update/lk.img` from the supplied V14 ZIP first.

```sh
python3 patch_is_enable_V14.0.4.0.py --input md1img.img --output md1img_v14_patched.img --dry-run
python3 patch_lk_md1_policy_V14.0.4.0.py --input lk.img --output lk_v14_patched.img --dry-run
```

For either version, remove `--dry-run` after successful checks to create the
outputs. Output files must not exist. Explicit paths avoid assumptions about
the original research folder layout. Both scripts use only Python's standard
library, check exact SHA-256 fingerprints, and never flash or re-sign anything.
The LK script also writes a JSON report with offsets, changes and hashes.

Both modem scripts support `--raw-rom` for an extracted `1_md1rom` member.
That output is not the complete modem image and must not be mistaken for one.
The default mode produces a complete modem container. Use separate output
names/directories for each firmware version.

These examples reproduce file edits, not a device upgrade procedure. Device
compatibility, accepted unlock state, active slot and remaining authentication
conditions must be established before flashing; see [verification](verification.md).
