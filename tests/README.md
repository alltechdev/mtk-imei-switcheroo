# Tests

Run commands from the repository root.

## Repository checks

```sh
python3 tests/check_docs.py
bash -n tools/nvram/*.sh tests/*.sh
```

The documentation check validates local Markdown links and heading anchors.
It requires only Python's standard library and does not access a device.

## NVRAM regression drivers

```sh
bash tests/mac_tool_edge_cases.sh
bash tests/live_patch_mac_preflight.sh
```

These require local samples under `tmp/wifi_bt_re/`: `BT_Addr.bin`, `WIFI.bin`
and, for the edge cases, `live_nvram.img`. Samples are not shipped. Optional
F25/TIQ M5 partition dumps enable additional round-trip checks; see the driver
for their paths. Missing required samples produce exit status 2.

The preflight driver uses mocked ADB for most cases and automatically runs
additional live cases if a rooted device is connected. It temporarily replaces
`mac_tool.py` during failure tests and restores it on exit. Run it in a disposable
checkout with disposable `tmp/` data; do not run it concurrently with tool use.

## Biloba audit regressions

```sh
python3 -m unittest discover -s tests -p 'test_biloba_audits.py' -v
```

Requires `cryptography` from `firmware/biloba/requirements.txt`. Synthetic fixtures
cover RSA and unsupported keys, corrupt ZIP members, and V4 seccfg hash placement
and malformed headers. No firmware samples or device are needed.

## Biloba firmware checks

See the [reproduction guide](../docs/biloba/reproduce.md). Each version uses
exact local originals and runs two MIPS caller cases plus 15 ARM execution cases.
The runner records hashes and results in a fresh, ignored run directory.
These checks do not establish hardware boot success.
