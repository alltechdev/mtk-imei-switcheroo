# Related projects and credits


- [`flipphoneguy/mtk-imei-switcheroo-app`](https://github.com/flipphoneguy/mtk-imei-switcheroo-app) — Java/Android port. Cross-verified bit-for-bit against this repo's tools:
  - **IMEI side** (against `imei_tool.py`): same AES key, slot offsets `{0x40, 0x60}`, plaintext layout, and MD5-XOR checksum.
  - **BT MAC + WiFi MAC side** (v1.0.5, against `mac_tool.py`): `MacCrypto.computeChecksum` is a direct Java port of `mac_tool.compute_checksum`. Verified equivalent on real partition samples — F21 Pro live + stock, F25, TIQ M5, F30 stock — every stored trailer byte computes the same on both implementations, and `patchBt` / `patchWifi` produce byte-identical output to `patch_bt` / `patch_wifi` for the same input. Their "supported device gate" is the trailer-checksum match itself, which transparently handles F25's `01 00 09 00` WIFI header without needing a header whitelist (because the patch path leaves the header untouched).

## Credits

- AES key derivation algorithm from [bkerler/mtkclient](https://github.com/bkerler/mtkclient).
- NVRAM call chain and `LD0B_001` structure from the [MTK MOLY modem source](https://github.com/hyperion70/HSPA_MOLY.WR8.W1449.MD.WG.MP.V16) (MT6592, predates MT67xx checksum).
- Modem firmware (`md1img_a.bin`) unpacked with [R0rt1z2/md1imgpy](https://github.com/R0rt1z2/md1imgpy) to confirm key-derivation constants byte-for-byte against the live binary.
- Standard GSM BCD encoding cross-checked against [chuacw/WriteIMEI](https://github.com/chuacw/WriteIMEI) and 3GPP TS 23.003.
- The MD5-XOR checksum (introduced in the MT67xx generation, not present in the leaked MOLY source or any open-source tool) was reverse-engineered black-box on the F21 Pro by decrypting known-good `LD0B_001` files and iterating write/reboot/verify cycles. Full provenance trace in [`docs/research/imei.md`](research/imei.md).
- Discovery and fix of the Android 12+ `WifiConfigStore.xml` cache (the `wifi_sta_factory_mac_address` field that `WifiService` seeds on first boot and then uses for "device MAC" / per-SSID randomization regardless of subsequent file changes) — credit to [`flipphoneguy/mtk-imei-switcheroo-app`](https://github.com/flipphoneguy/mtk-imei-switcheroo-app), which identified the cache while testing on F25 and shipped `RootRunner.syncAndroidWifiFactoryMac` in [v1.0.6](https://github.com/flipphoneguy/mtk-imei-switcheroo-app/commit/060697aae1167e3ef217bf7f58fcf867c0a79d9f); ported back into `live_patch_mac.sh` as `sync_android_wifi_factory_mac`.
