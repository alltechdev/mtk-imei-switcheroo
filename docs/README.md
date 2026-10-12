# Documentation

Commands in these guides run from the repository root. The four NVRAM tools
are grouped under `tools/nvram/`.

## Guides

- [Offline IMEI tool](guides/imei_tool.md)
- [Live IMEI patching](guides/live_patch.md)
- [Offline WiFi/Bluetooth tool](guides/mac_tool.md)
- [Live WiFi/Bluetooth patching](guides/live_patch_mac.md)
- [Biloba firmware patchers](biloba/patchers.md)
- [Biloba offline reproduction](biloba/reproduce.md)

## Formats and research

- [NVRAM overview](reference/overview.md)
- [IMEI record format and checksum](reference/imei_format.md)
- [IMEI reverse engineering](research/imei.md)
- [WiFi/Bluetooth reverse engineering](research/wifi_bt.md)
- [Biloba modem/LK changes and evidence](biloba/README.md)
- [Executable research helpers](../research/biloba/README.md)

## Devices

- [Validation status and test provenance](devices/validation.md)
- [F25 offline analysis](devices/f25.md)
- [TIQ M5 offline analysis](devices/tiq_m5.md)
- [TIQ M5 live MAC findings](devices/tiq_m5_live_mac.md)

## Development

- [Tests and local fixtures](../tests/README.md)
- [Related projects and credits](credits.md)

Use `guides/` for tool behavior, `reference/` for formats, `devices/` for
hardware observations and `research/` for derivations. Biloba's firmware-specific
documentation remains together under `biloba/`; its scripts and machine-readable
evidence live in the repository's `firmware/` and `research/` directories.
