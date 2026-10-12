# NVRAM tools

Run from the repository root:

| Tool | Purpose | Documentation |
| --- | --- | --- |
| `python3 tools/nvram/imei_tool.py` | Read/write IMEI records and partition images | [Guide](../../docs/guides/imei_tool.md) |
| `./tools/nvram/live_patch.sh` | Interactive rooted-device IMEI flow | [Guide](../../docs/guides/live_patch.md) |
| `python3 tools/nvram/mac_tool.py` | Read/write WiFi/BT records and images | [Guide](../../docs/guides/mac_tool.md) |
| `./tools/nvram/live_patch_mac.sh` | Interactive rooted-device WiFi/BT flow | [Guide](../../docs/guides/live_patch_mac.md) |

These files previously lived at the repository root. Update saved commands to
include `tools/nvram/`. Live scripts locate their Python helper beside themselves
and keep backups under `tmp/` in the current working directory.

Python 3.6+ is required. IMEI tools use the root `requirements.txt`; MAC tools
use the standard library. Live scripts also need ADB and a rooted device.
