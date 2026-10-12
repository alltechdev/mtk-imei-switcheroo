# NVRAM overview

On MediaTek MT67xx devices (verified on F21 Pro, F25, and TIQ M5), the modem firmware encrypts each IMEI in NVRAM using AES-128-ECB. The decrypted plaintext is a 32-byte block: BCD-encoded IMEI (8 bytes), a 2-byte filler at `[8:10]`, an 8-byte MD5-XOR checksum the modem validates on read, and 14 bytes of zero padding. For this IMEI record checksum, the 2-byte filler can be any value as long as the checksum is computed over it correctly. Single-SIM units (F21 Pro) populate one slot at `[0x40:0x60]`; dual-SIM units (F25, TIQ M5) populate a second at `[0x60:0x80]` with the same structure. This tool reimplements the encryption and the checksum so it can rewrite either IMEI without touching the device.

The AES key is `3f06bd14d45fa985dd027410f0214d22` — pre-computed once from MTK's standard NVRAM seed via the `SST_Get_NVRAM_SW_Key` derivation (see [bkerler/mtkclient](https://github.com/bkerler/mtkclient) for the algorithm) and hardcoded as `AES_KEY`.


See [the complete IMEI format](imei_format.md) and [the WiFi/BT investigation](../research/wifi_bt.md).
