# mtk-imei-switcheroo

Read and write IMEI records and WiFi/Bluetooth addresses in MediaTek NVRAM
files or partition images. Includes interactive ADB tools for rooted devices
and separate, version-specific modem/LK patchers for biloba.

## Install

```sh
git clone https://github.com/alltechdev/mtk-imei-switcheroo
cd mtk-imei-switcheroo
python3 -m pip install -r requirements.txt
```

The NVRAM tools need Python 3.6+. IMEI operations require `pycryptodome`;
WiFi/Bluetooth operations use only the standard library. Live tools also need
ADB and a rooted device. Biloba's full verification workflow has
[separate dependencies](docs/biloba/reproduce.md#dependencies).

## Choose a tool

| Task | Command | Guide |
| --- | --- | --- |
| IMEI in a local file or partition image | `python3 tools/nvram/imei_tool.py` | [Offline IMEI](docs/guides/imei_tool.md) |
| IMEI on a rooted device | `./tools/nvram/live_patch.sh` | [Live IMEI](docs/guides/live_patch.md) |
| WiFi/BT addresses in a local file or image | `python3 tools/nvram/mac_tool.py` | [Offline MAC](docs/guides/mac_tool.md) |
| WiFi/BT addresses on a rooted device | `./tools/nvram/live_patch_mac.sh` | [Live MAC](docs/guides/live_patch_mac.md) |
| Exact biloba modem/LK firmware pair | Versioned Python patchers | [Biloba patchers](docs/biloba/patchers.md) |

## Usage

Run from the repository root:

```sh
python3 tools/nvram/imei_tool.py read LD0B_001
python3 tools/nvram/imei_tool.py read nvdata.img
python3 tools/nvram/imei_tool.py write LD0B_001 350859600862948 -s 1 -o LD0B_001_new
# Dual-SIM: use -s 2 for the second slot.

python3 tools/nvram/mac_tool.py read WIFI
python3 tools/nvram/mac_tool.py write WIFI --wifi 02:11:22:33:44:66 -o WIFI.patched
python3 tools/nvram/mac_tool.py write BT_Addr --bt 02:11:22:33:44:55 -o BT_Addr.patched
```

Offline tools accept individual records or supported partition images. See the
guides for detection rules, duplicate records, backups and error handling.

## Live device patching

`./tools/nvram/live_patch.sh` and `./tools/nvram/live_patch_mac.sh` pull records, prompt for changes,
push the patched files and offer a reboot. Follow the
[live IMEI](docs/guides/live_patch.md) or [live MAC](docs/guides/live_patch_mac.md)
guide for requirements and verification.

## Verification status

| Device | Recorded result |
| --- | --- |
| F21 Pro | IMEI and WiFi/BT flows verified on hardware |
| F25 | IMEI verified through the tester; WiFi/BT confirmed through the Java port |
| TIQ M5 | Dual-SIM IMEI and WiFi/BT flows verified on hardware |
| Biloba V12 modem + supplied LK | Paired firmware patch reported working; modem-only patch bootlooped |
| Biloba V13 modem + bundled LK | Offline checks passed; no hardware result reported |
| Biloba V14 modem + bundled LK | Offline checks passed; no hardware result reported |

[Detailed validation](docs/devices/validation.md) distinguishes direct tests,
external reports and offline checks. Shared chipset identity does not establish
compatibility. Biloba adds a signed critical-data check; the NVRAM tools do not
apply its firmware changes. See [biloba status and limits](docs/biloba/README.md).

## WiFi MAC and Bluetooth address

Android's per-network MAC randomization can hide the device address. Android
12+ also caches the factory WiFi MAC; the live script updates that cache,
whereas an offline partition edit alone does not. See
[live MAC behavior](docs/guides/live_patch_mac.md) and
[device findings](docs/devices/tiq_m5_live_mac.md).

## Repository layout

| Location | Purpose |
| --- | --- |
| [tools/nvram/](tools/nvram/README.md) | Offline NVRAM tools and live ADB scripts |
| [docs/](docs/README.md) | Guides, formats, device findings and research explanations |
| [firmware/biloba/](firmware/biloba/README.md) | Versioned firmware patchers and reproduction runner |
| [research/biloba/](research/biloba/README.md) | Analysis helpers, execution harnesses and saved evidence |
| [tests/](tests/README.md) | NVRAM regression drivers and repository checks |
| `tmp/`, `runs/` | Ignored local samples, backups and generated results |

Firmware images, partition dumps and private keys are not included.

## Related

[Android app port](https://github.com/flipphoneguy/mtk-imei-switcheroo-app) ·
[Credits and provenance](docs/credits.md) · [License](LICENSE)
