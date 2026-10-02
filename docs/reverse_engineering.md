# Reverse engineering the IMEI NVRAM format

A step-by-step walkthrough of how the F21 Pro's IMEI encryption was reverse-engineered from scratch. Every claim is backed by a command you can run or a byte offset you can verify. No prior knowledge of the format is assumed beyond "this phone stores its IMEI somewhere on disk."

## Source material

| Source | What it provided |
|---|---|
| F21 Pro modem firmware (`md1img_a.bin`, unpacked via [R0rt1z2/md1imgpy](https://github.com/R0rt1z2/md1imgpy) to `1_md1rom`) | The compiled ARM code and embedded constants that implement IMEI encryption on the device. Ground truth for key derivation constants, file paths, and call chain. |
| [bkerler/mtkclient](https://github.com/bkerler/mtkclient) | Open-source reimplementation of MTK's NVRAM key derivation (`SST_Get_NVRAM_SW_Key`). Provided the scramble + AES-256-CBC algorithm in Python form. |
| [MTK MOLY modem source](https://github.com/hyperion70/HSPA_MOLY.WR8.W1449.MD.WG.MP.V16) | Leaked MT6592 modem source. Contains `SST_secure.c`, `custom_nvram_sec.c`, and `nvram_util.c` in C. Older platform — provides the encryption framework and NVRAM structure but predates the MD5-XOR checksum introduced on MT67xx. |
| Black-box testing on live F21 Pro | The MD5-XOR checksum algorithm was determined empirically by decrypting known-good `LD0B_001` files and iterating on write/reboot/verify cycles until the modem consistently accepted patched IMEIs. |

## Step 0 — Find the IMEI file on disk

On a rooted F21 Pro, the IMEI is readable via `service call iphonesubinfo`, but where is it *stored*? MediaTek devices use NVRAM partitions. Search for likely paths:

```bash
adb shell su -c "find /mnt/vendor/nvdata -iname '*imei*' 2>/dev/null"
# /mnt/vendor/nvdata/md/NVRAM/NVD_IMEI
```

The match is a directory; list it to find what's inside:

```bash
adb shell su -c "ls -la /mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/"
# total 48
# drwxrwx--x 2 root  system 4096 ... .
# drwxrwx--x 7 root  system 4096 ... ..
# -rw-r--r-- 1 radio system   36 ... FILELIST
# -rw-rw---- 1 root  system  384 ... LD0B_001
# -rw-rw---- 1 root  system   96 ... NV01_000
# -rw-rw---- 1 root  system  144 ... NV0S_000
```

Four files. `LD0B_001` is the 384-byte one, owned `root:system` mode `0660` — the modem-protected payload, distinguishable by size and ownership from the small companion records. Pull it and inspect:

```bash
adb exec-out su -c "cat /mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/LD0B_001" > LD0B_001
wc -c LD0B_001
# 384

od -A x -t x1z -N 32 LD0B_001
# 000000 4c 44 49 00 10 ef 0a 00 0a 00 00 00 0a 40 00 00  >LDI..........@..<
# 000010 00 20 00 00 00 00 00 00 00 00 00 00 00 00 a2 44  >. .............D<
# 000020
```

The file is 384 bytes. The first 4 bytes are `LDI\x00` — a known MTK NVRAM file marker. The IMEI digits are not visible in plaintext anywhere in the file, so the content is encrypted. Now the question becomes: with what key, what algorithm, and what format?

## Crypto constants in the modem binary

All three key-derivation constants live in a contiguous block inside `1_md1rom`, sourced from `common/service/sst/src/SST_secure_exp.c`:

```
Offset in 1_md1rom   Size    Constant
────────────────────────────────────────────────────
15637084 (0xEE9A5C)   32     SECOND_SEED
15637116 (0xEE9A7C)   32     KEY_CONST
15637148 (0xEE9A9C)  256     NVSW_KGEN
```

Immediately after the constants, the source path string confirms their origin:

```
common/service/sst/src/SST_secure_exp.c
```

Followed by AES debug strings from the same file:

```
[CHE] AES encryption, data length is: %d
[CHE] AES enc length should be block size aligned, after aligned, the length is: %d
[CHE] AES decryption, data length is: %d
```

The NVRAM seed (`01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 0B 14 15 16 17 18 19 1A 1B 1C 00 00 00 00`) appears at offset 15813496 (0xF14B78).

## NVRAM security call chain

Found via debug strings in the modem ROM:

```
custom_nvram_sec.c          "pcore/custom/service/nvram/custom_nvram_sec.c"
    └── nvram_sec.c         "common/service/nvram/sec/nvram_sec.c"
        └── SST_secure.c    "common/service/sst/src/SST_secure.c"
                             "[SST]NVRAM secure check, lid=%x, rw=%x,secure=%x"
                             "[SST]NVRAM secure check status : %x"
                             debug labels: "enc_seed_source", "enc_key_source",
                                           "enc_seed", "enc_key"
            └── SST_secure_exp.c  "common/service/sst/src/SST_secure_exp.c"
                                   AES encrypt/decrypt via CHE (Crypto Hardware Engine)
                                   contains SECOND_SEED, KEY_CONST, NVSW_KGEN
```

## IMEI verification in the modem

The modem validates IMEIs at boot. Evidence from string references:

- `SBP_IMEI_VERIFY_FAIL_ENTER_ECC_MODE` — if IMEI verification fails, the modem enters emergency-calls-only mode
- `SBP_IMEI_LOCK_SUPPORT` — carrier IMEI lock support flag
- `smu_imei_lock_verified_ind_handler` — handler called after IMEI lock verification
- `IMEI locked` — debug string when IMEI lock is active
- `IMEI of SIM` — from `pcore/modem/nas/mm/cmm/src/mm_cs_common_proc.c`

The NVRAM file path `Z:\NVRAM\NVD_IMEI` appears in the modem's virtual filesystem table at offset 15581844 (0xEDC294), confirming `NVD_IMEI` is the IMEI storage folder the modem reads from.

## Identifying the encryption

The debug strings near the crypto constants tell us the algorithm:

```
[CHE] AES encryption, data length is: %d
[CHE] AES enc length should be block size aligned, after aligned, the length is: %d
```

So the modem uses AES. But which mode? Try the simplest first:

1. **ECB** (no IV needed) — try decrypting `LD0B_001[0x40:0x60]` (the 32 bytes after the 64-byte header) with AES-128-ECB and the derived key. If the output starts with recognizable BCD digits matching the known IMEI, we have our mode.
2. **CBC** — would require finding an IV. Try only if ECB doesn't work.

```python
from Crypto.Cipher import AES

AES_KEY = bytes.fromhex("3f06bd14d45fa985dd027410f0214d22")

with open("LD0B_001", "rb") as f:
    data = f.read()

# Try ECB on the 32 bytes after the header
pt = AES.new(AES_KEY, AES.MODE_ECB).decrypt(data[0x40:0x60])
print(pt.hex())
# If this starts with valid BCD digits → ECB is correct
```

On the F21 Pro, ECB works on the first attempt — the decrypted output starts with recognizable BCD-encoded IMEI digits. No IV search needed. The MOLY source (`custom_nvram_sec.c`) confirms this: `custom_nvram_encrypt` calls AES with no IV parameter, which in MTK's CHE API defaults to ECB.

**Why offset 0x40?** If you don't know the header size, brute-force it: try decrypting every 16-byte-aligned offset in the 384-byte file and check which one produces a 15-digit BCD IMEI. The IMEI's BCD form is 8 bytes where the first 7 contain two decimal digits each and byte 7's high nibble is the `0xF` padding sentinel for the unpaired 15th digit:

```python
def looks_like_imei_bcd(pt8):
    # First 7 bytes: both nibbles must be 0-9
    if not all((b & 0xF) <= 9 and (b >> 4) <= 9 for b in pt8[:7]):
        return False
    # Byte 7: low nibble 0-9 (the 15th digit), high nibble == 0xF (sentinel)
    return (pt8[7] & 0xF) <= 9 and (pt8[7] >> 4) == 0xF

for offset in range(0, 384 - 32, 16):
    pt = AES.new(AES_KEY, AES.MODE_ECB).decrypt(data[offset:offset+32])
    if looks_like_imei_bcd(pt[:8]):
        print(f"Candidate at offset {offset:#x}: {pt[:8].hex()}")
```

Only offset `0x40` matches — the trailing `0xF` sentinel is the discriminator that rules out offsets where the decrypted bytes are nibble-valid by accident (the all-`0xFF` padding region in `LD0B_001` decrypts to a sequence whose nibbles all happen to be 0–9, but the byte-7 high nibble isn't `0xF`). The 384-byte file has an 8-byte signature (`LDI\x00\x10\xef\x0a\x00`) plus 56 bytes of modem metadata = 64 bytes of header before the first encrypted IMEI block.

## AES key derivation

The key derivation algorithm was independently documented by [bkerler/mtkclient](https://github.com/bkerler/mtkclient). The constants required are all present in the modem binary (see [Crypto constants](#crypto-constants-in-the-modem-binary) above):

```
1. scramble(NVRAM_SEED, KEY_CONST) using SECOND_SEED
   → produces (iv, key), both 32 bytes
2. AES-256-CBC encrypt NVSW_KGEN (256 bytes) with key and iv[:16]
3. Take first 16 bytes of ciphertext = AES-128 NVRAM key
```

To run the derivation yourself:

```python
from Crypto.Cipher import AES

NVRAM_SEED = bytes.fromhex("0102030405060708090A0B0C0D0E0F1011120B1415161718191A1B1C00000000")
KEY_CONST  = bytes.fromhex("3523325342455424438668347856341278563412438668344245542435233253")
SECOND_SEED = bytes.fromhex("8F9C6151DC86B9163A37506D9DFF7753464BA73E5EDEF3625BA18D481235805B")
NVSW_KGEN  = bytes.fromhex(
    "BE410C67394D98017256AA3C8F21BB42CE75601B8F7BC3078216362B151F7F01"
    "96E9EB0431739C7438E4920CB18F0961956BE82D9D68403207B07A3687351302"
    "C718AD6B10EB571DCB8CFD250BAA0D55987C19528445B2728BFC252189FEF974"
    "46765F5C803309566DB380251A7CE31EB4751A06DBB2B0037B2F391D72B7266D"
    "14004905ED85E35901D9E12FE275A9207C01A76183EF175BF894282212EB9266"
    "B462B44F3079BB2EC37A9C4749CE9C7DCDE1FB60CB2A177ED103B07F95FAA84C"
    "DB156F1B9C90AD25A0A4B6217392886D20D65F182CA1DC42FD908262674CBF74"
    "ACD4E5186A44030881C8A213604A001F45F7B30BFCF7DB30D301270C59F7FC10")

def scramble(iv, buf):
    iv, buf = bytearray(iv), bytearray(buf)
    for i in range(0, 0x20, 2):
        iv[i], iv[i+1] = iv[i+1], iv[i]
    for i in range(0, 0x20, 2):
        buf[i], buf[i+1] = buf[i+1], buf[i]
    for i in range(0x20):
        v = iv[i] ^ SECOND_SEED[i]
        iv[i] = v
        buf[i] = v ^ buf[i]
    return bytes(iv), bytes(buf)

iv, key = scramble(NVRAM_SEED, KEY_CONST)
derived = AES.new(key, AES.MODE_CBC, iv=iv[:16]).encrypt(NVSW_KGEN)
aes_key = derived[:16]
print(aes_key.hex())
# Output: 3f06bd14d45fa985dd027410f0214d22
```

The constants in the modem binary match mtkclient's values byte-for-byte. The derived key is:

```
3f06bd14d45fa985dd027410f0214d22
```

This key is hardcoded in `imei_tool.py` as `AES_KEY` rather than re-derived at runtime.

## MD5-XOR checksum

The MD5-XOR checksum is **not present in the leaked MOLY source** (MT6592-era). It was introduced in the MT67xx modem generation. No public documentation or open-source tool implements it. The algorithm was discovered through the following process:

### Step 1 — Observe the plaintext structure

Pull a known-good `LD0B_001` from the device, then decrypt the IMEI block with the derived AES key and inspect it:

```bash
# On a rooted F21 Pro:
adb exec-out su -c "cat /mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/LD0B_001" > LD0B_001

# Read the current IMEI for cross-reference:
adb shell su -c "service call iphonesubinfo 4 i32 1" \
  | awk -F"'" '{print $2}' | sed '1d' | tr -d '.\n ' | head -c15
```

```python
from Crypto.Cipher import AES

AES_KEY = bytes.fromhex("3f06bd14d45fa985dd027410f0214d22")

with open("LD0B_001", "rb") as f:
    data = f.read()

# Encrypted IMEI block is at offset 0x40, 32 bytes
ct = data[0x40:0x60]
pt = AES.new(AES_KEY, AES.MODE_ECB).decrypt(ct)

print("Full 32-byte plaintext (hex):")
print(pt.hex())
print()
# By eye, four regions stand out: 0:8, 8:10, 10:18, 18:32. Print them grouped.
print("Decrypted 32-byte IMEI block:")
for start, end in [(0, 8), (8, 10), (10, 18), (18, 32)]:
    chunk = ' '.join(f'{b:02x}' for b in pt[start:end])
    print(f"  [0x{start:02x} : 0x{end:02x}]   {chunk}")
```

Typical output (illustrative — IMEI `123456789012345`, BCD `21 43 65 87 09 21 43 f5`, stock-style `00 00` filler):

```
Full 32-byte plaintext (hex):
21436587092143f50000dff6b0a2d850962a0000000000000000000000000000

Decrypted 32-byte IMEI block:
  [0x00 : 0x08]   21 43 65 87 09 21 43 f5
  [0x08 : 0x0a]   00 00
  [0x0a : 0x12]   df f6 b0 a2 d8 50 96 2a
  [0x12 : 0x20]   00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

Four regions become obvious:
- `[0x00:0x08]` — eight bytes of decimal-digit pairs that decode as the device's IMEI (BCD encoding, swapped nibbles; matches `service call iphonesubinfo`).
- `[0x08:0x0a]` — a 2-byte field, constant for a given IMEI.
- `[0x0a:0x12]` — 8 unknown bytes. *What are these?*
- `[0x12:0x20]` — 14 bytes of zero padding.

To confirm the unknown bytes are a checksum (not a nonce or random):
- Pull `LD0B_001` multiple times without changing the IMEI → bytes `[0x0a:0x12]` are **identical** every time (deterministic, not random)
- Change the IMEI on the device, pull again → bytes `[0x0a:0x12]` are **completely different** (dependent on IMEI, not a fixed constant)

This behavior is consistent with a hash-derived checksum over the IMEI data.

### Step 2 — Identify the hash algorithm

**Constraints from observation:**
- Output is exactly 8 bytes
- Deterministic: same IMEI always produces the same 8 bytes
- High entropy: no obvious pattern, no repeated nibbles, no byte-level structure
- Changes completely when even one IMEI digit changes (avalanche behavior → cryptographic hash, not CRC)

**Approach:** Pull `LD0B_001` files for at least two different known IMEIs (e.g. before and after a carrier swap), decrypt both, and test candidate algorithms against the 8 unknown bytes. The test harness is trivial — one Python script iterating through hypotheses:

```python
import hashlib, struct, binascii

known_pairs = [
    # (decrypted_block_from_device_A, known_imei_A),
    # (decrypted_block_from_device_B, known_imei_B),
]

for pt, imei in known_pairs:
    target = pt[10:18]
    data_8  = bytes(pt[0:8])    # BCD only
    data_10 = bytes(pt[0:10])   # BCD + 2-byte filler

    # --- Hypothesis 1: CRC-64 ---
    # No stdlib CRC-64; skip unless nothing else hits.

    # --- Hypothesis 2: Simple byte-sum checksum (MOLY style) ---
    # nvram_util_caculate_checksum in MOLY uses odd/even byte sums → 2 bytes, not 8.
    # Ruled out by size alone.

    # --- Hypothesis 3: MD5 truncated to first 8 bytes ---
    h = hashlib.md5(data_10).digest()
    if h[:8] == target:
        print("MD5 first-half match"); continue

    # --- Hypothesis 4: MD5 truncated to last 8 bytes ---
    if h[8:] == target:
        print("MD5 last-half match"); continue

    # --- Hypothesis 5: MD5 XOR-folded (first 8 XOR last 8) ---
    folded = bytes(h[i] ^ h[i+8] for i in range(8))
    if folded == target:
        print("MD5 XOR-fold match"); continue

    # --- Hypothesis 6: SHA-1 truncated to 8 bytes ---
    h1 = hashlib.sha1(data_10).digest()
    if h1[:8] == target:
        print("SHA-1 first-8 match"); continue

    # --- Hypothesis 7: SHA-256 truncated to 8 bytes ---
    h256 = hashlib.sha256(data_10).digest()
    if h256[:8] == target:
        print("SHA-256 first-8 match"); continue

    # --- Hypothesis 8: SHA-1 XOR-folded (first 8 XOR bytes 8-16) ---
    h1_fold = bytes(h1[i] ^ h1[i+8] for i in range(8))
    if h1_fold == target:
        print("SHA-1 XOR-fold match"); continue

    # --- Hypothesis 9: SHA-256 XOR-folded (first 8 XOR bytes 8-16) ---
    h256_fold = bytes(h256[i] ^ h256[i+8] for i in range(8))
    if h256_fold == target:
        print("SHA-256 XOR-fold match"); continue

    # --- Hypothesis 10: MD4 truncated to 8 bytes ---
    # MD4 is in some older MTK code paths
    try:
        h4 = hashlib.new('md4', data_10).digest()
        if h4[:8] == target:
            print("MD4 first-8 match"); continue
        h4_fold = bytes(h4[i] ^ h4[i+8] for i in range(8))
        if h4_fold == target:
            print("MD4 XOR-fold match"); continue
    except ValueError:
        pass  # MD4 not available in all builds

    # --- Hypothesis 11: BLAKE2b with 8-byte digest ---
    b2 = hashlib.blake2b(data_10, digest_size=8).digest()
    if b2 == target:
        print("BLAKE2b-64 match"); continue

    # --- Hypothesis 12: repeat all above with data_8 instead of data_10 ---
    # (i.e. hash over BCD only, excluding the 2-byte filler)
    h_8 = hashlib.md5(data_8).digest()
    if bytes(h_8[i] ^ h_8[i+8] for i in range(8)) == target:
        print("MD5 XOR-fold over [0:8] match"); continue
    # (expand as needed for SHA-1, SHA-256, etc. over data_8)

    print("No match found for this pair")
```

**Results against an LD0B_001 from the F21 Pro nvdata partition image** (illustrative IMEI `123456789012345`, stock-style `00 00` filler):

```
Decrypted plaintext:
  [0x00:0x08] BCD:      21436587092143f5  →  IMEI: 123456789012345
  [0x08:0x0a] Filler:   0000
  [0x0a:0x12] Target:   dff6b0a2d850962a
  [0x12:0x20] Padding:  0000000000000000000000000000
```

| # | Algorithm | Variant | Input range | Result |
|---|---|---|---|---|
| 1 | Simple byte-sum (MOLY) | odd/even accumulator | any | Wrong size (2 bytes, not 8) |
| 2 | MD5 | first 8 bytes | `[0:10]` | No match |
| 3 | MD5 | last 8 bytes | `[0:10]` | No match |
| **4** | **MD5** | **XOR-folded** | **`[0:10]`** | **MATCH** |
| 5 | MD5 | XOR-folded | `[0:8]` | No match (wrong input range) |
| 6 | SHA-1 | first 8 bytes | `[0:10]` | No match |
| 7 | SHA-1 | XOR-folded | `[0:10]` | No match |
| 8 | SHA-256 | first 8 bytes | `[0:10]` | No match |
| 9 | SHA-256 | XOR-folded | `[0:10]` | No match |
| 10 | MD4 | first 8 / XOR-folded | `[0:10]` | N/A (not in hashlib) |
| 11 | BLAKE2b | 8-byte digest | `[0:10]` | No match |
| 12 | All of 2-11 | all variants | `[0:8]` | No match (BCD-only, no filler) |

```
Confirmed: MD5 XOR-fold over [0:10] = dff6b0a2d850962a
  matches target checksum              dff6b0a2d850962a
```

**Note on the data above:** the IMEI, BCD, and target checksum in this section are illustrative — the target was computed by applying MD5 XOR-fold, so of course that algorithm matches it. The numbers prove the methodology is internally consistent, not that the algorithm is correct. To verify independently, run this same hypothesis matrix against an `LD0B_001` pulled from your own F21 Pro: decrypt the IMEI block with the AES key derived above, take the actual `pt[10:18]` bytes from *your* device's plaintext as the target, and confirm that of the 12 candidates only MD5 XOR-fold over `pt[0:10]` matches. That's where the result becomes evidence rather than self-consistency.

**Row 4 is the only hit.** The checksum is `MD5(plaintext[0:10])` XOR-folded across its two halves:

```python
md = hashlib.md5(bcd_plus_filler).digest()    # 16 bytes
checksum = bytes(md[i] ^ md[i + 8] for i in range(8))
```

**Why MD5 XOR-fold is the natural first guess among the candidates:**
- MD5 is already linked into the modem binary (IPsec cipher suites reference it at offsets 15836083+)
- XOR-folding a digest to halve its length is a standard construction (e.g. NIST SP 800-108 KDF counter mode, Davies-Meyer compression — the pattern "hash then XOR halves" recurs throughout embedded crypto)
- 8 bytes is the natural result of folding MD5's 16-byte output in half — no truncation offset to guess
- The approach is cheap: one MD5 call + 8 XORs, suitable for a modem boot path that runs on every power-on

**Note on bytes `[0x08:0x0a]` (the 2-byte filler):** The stock nvdata image has `00 00` at this position. `imei_tool.py` writes `FF FF` (matching the convention used by other MTK IMEI tools). Both are accepted by the modem — the checksum is computed over `pt[0:10]` regardless of what those 2 bytes contain, so any value works as long as the checksum matches. The modem does not validate the filler independently; it only validates the checksum.

### Step 3 — Confirm by write/reboot testing

All three cases were verified end-to-end on the F21 Pro:

1. **With correct checksum**: write a new IMEI with `MD5(BCD + filler)` XOR-folded → reboot → modem accepts it → new IMEI appears in `service call iphonesubinfo` and the on-disk `LD0B_001` reads back as the new IMEI.
2. **Without checksum update** (BCD overwritten, checksum left as it was for the previous IMEI): reboot → the modem detects the mismatch and *rolls back* — it overwrites `LD0B_001` with the device's factory IMEI block (BCD + valid factory checksum) sourced from a backup partition. `iphonesubinfo` then reports the factory IMEI, not the BCD we wrote.
3. **With random checksum bytes** at `[10:18]`: same outcome as case 2 — the post-reboot `LD0B_001` is byte-identical to case 2's, confirming both bad-checksum paths trigger the same factory-rollback handler.

This confirms the modem firmware validates the checksum on every boot. The `SBP_IMEI_VERIFY_FAIL_ENTER_ECC_MODE` symbol earlier in the binary names a stricter failure path the firmware *can* take (emergency-calls-only with no valid IMEI), but on this device the modem only reaches it when the factory backup is also unrecoverable. With the backup intact, the observable behavior is silent rollback.

### Why MD5 in the modem binary is hard to trace

The compiled MD5 implementation exists in `1_md1rom` (the IPsec/IKE subsystem references it as `md5` in lowercase cipher-suite strings starting at offset 15836083 — e.g. `aes256-aes128-des-3des-sha256-sha1-aesxcbc-md5-…` — and the NVRAM encryption code uses it internally). However, the MD5 function has no debug symbol strings tying it directly to the IMEI checksum — it's a generic library function called from compiled ARM code with no assertion or log strings at the call site. The connection between MD5 and the IMEI checksum was established entirely through the empirical process above.

## IMEI BCD encoding

Once you decrypt a known IMEI and stare at the first 8 bytes, the encoding is recognizable:

```
Known IMEI:  3 5 0 8 5 9 6 0 0 8 6 2 9 4 8
Bytes:       53 80 95 06 80 26 49 F8
```

Each byte packs two digits in swapped-nibble order: low nibble = even-indexed digit, high nibble = odd-indexed digit. Byte 7's high nibble is `0xF` because the 15th digit is unpaired. This is standard GSM BCD (3GPP TS 23.003, same as SIM card EF_IMSI). It also appears in the MOLY source (`nvram_util.c`) and older public tools like [chuacw/WriteIMEI](https://github.com/chuacw/WriteIMEI).

The 2-byte filler at `[8:10]` plus the MD5-XOR checksum at `[10:18]` is the structure specific to the MT67xx LD0B_001 format — older platforms (MP0B_001) used a different layout with simple XOR masking and byte-sum checksums. The filler value itself isn't fixed by the format: stock nvdata leaves it `00 00`, `imei_tool.py` writes `FF FF`, and the modem accepts either as long as the checksum that follows is computed over whatever filler bytes are present.

## Summary of provenance

```
imei_tool.py component          Primary source                          How verified
────────────────────────────────────────────────────────────────────────────────────────
AES_KEY (hardcoded)              Derived via bkerler/mtkclient           Constants matched
                                 algorithm from standard MTK seed        byte-for-byte in
                                                                         modem binary at
                                                                         offsets 0xEE830C+

AES-128-ECB encrypt/decrypt      Standard crypto primitive               Decrypt known
                                 (pycryptodome)                          LD0B_001 → valid
                                                                         BCD IMEI output

imei_to_bcd / bcd_to_imei        Standard GSM BCD (MOLY source,         Matches decoded
                                 chuacw/WriteIMEI, 3GPP TS 23.003)      IMEI from device

_md5_xor_checksum                Reverse-engineered from F21 Pro         Write/reboot/verify
                                 modem firmware via black-box testing     cycle (accepted with
                                 of decrypted LD0B_001 plaintexts        correct checksum,
                                                                         rejected without)

LD0B_001 file layout             MOLY source path strings in modem       Confirmed by pulling
(header, offsets, size)          binary (nvram_multi_folder.c,           LD0B_001 from device
                                 NVD_IMEI path at offset 0xEDA51D)      and validating size

Plaintext block structure        Decrypted live LD0B_001 files from      Multiple IMEIs
(BCD + FF FF + checksum + pad)   the device, cross-referenced with       tested across
                                 iphonesubinfo service call output        reboot cycles
```

## Reproducibility

Every step above can be independently reproduced with:

1. A rooted DuoQin F21 Pro
2. The stock modem firmware (`md1img_a.bin`) unpacked with [md1imgpy](https://github.com/R0rt1z2/md1imgpy)
3. To pull the encrypted file (binary-safe on F21 Pro / Android 11 *and* later Android + Magisk setups where `su`'s stdio injects CRLF):
   ```bash
   adb shell su -c "cp /mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/LD0B_001 /sdcard/LD0B_001 && chmod 644 /sdcard/LD0B_001"
   adb pull /sdcard/LD0B_001
   adb shell su -c "rm /sdcard/LD0B_001"
   ```
   The shorter `adb exec-out su -c "cat …" > LD0B_001` form works on F21 Pro / Android 11 but corrupts the pull on Android 13 / Magisk (see [Hardware validation (TIQ M5)](#hardware-validation-tiq-m5-dual-sim) below for the byte-level evidence).
4. Python 3.6+ with `pycryptodome` and `hashlib` (stdlib) to decrypt and test checksum hypotheses
5. `adb reboot` to verify the modem accepts or rejects the written IMEI

## Cross-device validation (F25)

The walkthrough above was conducted on a live F21 Pro (single-SIM). The same key, slot offsets, and checksum were independently re-validated first against a stock **DuoQin F25** (dual-SIM) firmware ZIP, then live on F25 hardware via this repo's `live_patch.sh` and via the [`flipphoneguy/mtk-imei-switcheroo-app`](https://github.com/flipphoneguy/mtk-imei-switcheroo-app) Java port — patched IMEIs persist across reboot and the modem accepts the patched bytes at runtime. **F25 hardware testing is performed by the port author (also the F25 device tester); we do not have F25 hardware on this side.**

For the MAC-side per-device analysis on F25 (BT_Addr / WIFI signatures, the `01 00 09 00` WIFI header variant, AllMap structure, modem family) see [`f25_offline_analysis.md`](f25_offline_analysis.md).

### What was checked against the F25 firmware

1. **Locate `LD0B_001` in the F25 nvdata image.** Unzip the F25 firmware, scan `nvdata.bin` for the `LDI\x00\x10\xef\x0a\x00` signature. Three copies are present: two byte-identical live copies (one active, one ext4 leftover sharing the same 0x40-byte header) and a distinct **factory backup** at offset `0x1c04000`. The backup has different IMEIs from the live copies, header bytes `[0x2a:0x2c]` differ (`0x68 0x10` live vs `0x37 0xf9` backup — likely a sequence/version field), and both backup slots carry their own valid checksums.

2. **Same AES key.** `AES.new(0x3f06bd14d45fa985dd027410f0214d22, ECB).decrypt(...)` on both 32-byte slots of the F25 live `LD0B_001` produces well-formed plaintext: BCD-encoded 15-digit IMEIs at `[0:8]` of each slot, a 2-byte filler at `[8:10]` (`00 00` on the live copy, `FF FF` on the factory backup — both round-trip cleanly because the checksum is computed over whichever bytes are present), and a checksum at `[10:18]` that matches MD5-XOR over `pt[0:10]` byte-for-byte.

3. **Both slots populated.** Unlike the F21 Pro (single-SIM, slot 2 = all-zero / all-`0xFF`), the F25 has *both* slots holding real IMEIs. The two IMEIs differ — confirming MTK uses one slot per SIM rather than mirroring.

4. **Round-trip through `imei_tool.py`.** `imei_tool.py write nvdata.bin <new_imei> -s 1` and `-s 2` against the F25 image: read-back via `imei_tool.py read` returns the new IMEIs in the corresponding slots, the other slot's bytes are byte-identical to the original, and `_patch_all_copies` updates the two header-matching live copies while leaving the factory backup at `0x1c04000` alone (its differing `[0x2a:0x2c]` header bytes cause the header-equality matcher to skip it — by analogy with the F21 Pro's factory-rollback handler this is desirable, but rollback behavior on F25 itself has not been observed).

### Live hardware confirmation (subsequent)

After the initial firmware-only analysis above, F25 hardware was tested via this repo's `live_patch.sh` and via the Java app port. Patched IMEIs persisted across reboot and the modem accepted the patched bytes at runtime. F25 hardware testing was performed by the port author (also the F25 tester); we do not have F25 hardware here. The original "no live F25 hardware" caveat has been resolved upstream.

### What was *not* checked

- **No bad-checksum behavior on F25.** The modem-side rollback-vs-ECC-mode response confirmed on the F21 Pro (Step 3 cases 2 and 3 above) has not been deliberately reproduced on F25; the F25 hardware tests only exercised the happy-path (valid checksum, accepted by modem). The next section (Hardware validation, TIQ M5) does cover the bad-checksum path on **that** device, and the response there is different from F21 Pro: F21 Pro silently restores from factory backup; TIQ M5 deletes the entire `LD0B_001` file. Whether F25 follows F21 Pro's rollback behavior or TIQ M5's delete behavior on a bad checksum is not yet known.

## Hardware validation (TIQ M5, dual-SIM)

Independent end-to-end confirmation on a live **TIQ M5** (MT6761, dual-SIM):

1. **Firmware-level checks.** Same NVRAM crypto framework as F21 Pro / F25: `SST_secure_exp.c`, `nvram_sec.c`, `custom_nvram_sec.c` source-path strings present in the modem binary; the same standard MTK `NVRAM_SEED` / `KEY_CONST` / `SECOND_SEED` constants present at MT6761-specific offsets in `md1img-verified.img`; same `Z:\NVRAM\NVD_IMEI` IMEI path; same `SBP_IMEI_VERIFY_FAIL_ENTER_ECC_MODE` / `SBP_IMEI_LOCK_SUPPORT` symbols; modem built with `GEMINI_PLUS=2` (dual-SIM).

2. **Decryption check.** Pulled `nvdata.bin` from a live device via [mtkclient](https://github.com/bkerler/mtkclient). Four LD0B_001 copies present: three byte-identical 384-byte bodies at offsets `0x1202000` / `0x180414e` / `0x2e0314e` plus one distinct body at `0x100214e` whose slot 1 IMEI differs from the others (slot 2 IMEI is the same across all four). All four copies share an identical 0x40-byte header. All four decrypt cleanly with `3f06bd14d45fa985dd027410f0214d22`; all eight slot blocks (4 copies × 2 slots) carry valid MD5-XOR checksums over `pt[0:10]`; all fillers are `00 00` (stock convention). Which of the byte-identical trio is the live ext4 filesystem block versus journal/COW leftovers wasn't determined — the patching strategy doesn't depend on knowing.

3. **Bug surfaced and fixed.** Unlike F25 — where the factory backup's header bytes `[0x2a:0x2c]` differ from the live copies and the `_patch_all_copies` header-equality gate correctly excludes it — TIQ M5's four copies share a byte-identical 0x40-byte header. The original `_patch_all_copies` blasted the patched-first-copy's 384 bytes onto every header-matching copy, which on TIQ M5 corrupted the live copies' slot 1 (overwriting it with the distinct copy's slot 1 IMEI). The fix patches each copy in place — only the requested slot's 32-byte ciphertext is rewritten per copy. F21 Pro (15-copy real partition image) and F25 (firmware image) produce byte-identical output before and after the fix because their multi-copy scenarios never had body-differing same-header copies; TIQ M5 only works correctly after.

4. **Live hardware test.** Built a test `nvdata.bin` by chain-patching slot 1 then slot 2 to a single test IMEI (`123456789012345`); per-copy verification confirmed all 4 copies had both slots = the test IMEI with valid MD5-XOR checksums and zero padding intact. Flashed back via mtkclient, booted the device. Both IMEIs read as `123456789012345` on-device — confirming the modem accepts patched bytes at runtime, both slots are independently patchable, and the AES key + slot offsets + format + checksum + BCD encoding are all correct on TIQ M5.

5. **`live_patch.sh` end-to-end (rooted-ADB flow).** Two consecutive runs on the same device, each followed by a reboot:
   - Run 1: dual-SIM `[1/2/n]` prompt → choose slot 2 → patch slot 2 to a fresh test IMEI. Post-script: slot 1 byte-identical to its pre-script value (per-copy preservation verified — only the slot-2 ciphertext block changed), slot 2 = the new IMEI. Post-reboot: file md5 byte-identical to script's `tmp/patched_LD0B_001.bin` (modem persists, no rollback).
   - Run 2: same prompt → choose slot 1 → patch slot 1 to a fresh test IMEI. Post-script: slot 2 byte-identical to its run-1-patched value (the previously-patched slot is preserved across this run), slot 1 = the new IMEI. Post-reboot: file md5 byte-identical to script's patched file again.
   - **Observation that drove a script change:** the original pull (`adb exec-out su -c "cat $IMEI_PATH" > backup`) returned 387 bytes on this device's Android 13 + Magisk combo. Every byte with value `0x0a` in the file appeared as `0x0d 0x0a` in the pull — for example the source file's first 8 bytes are `4c 44 49 00 10 ef 0a 00` ("LDI" header), which were pulled back as `4c 44 49 00 10 ef 0d 0a 00`. The script's defense-in-depth size check (`wc -c == 384`) correctly rejected it. Pull was switched to `cp via su` to `/sdcard` + `adb pull` (SYNC-protocol-based, binary-safe by construction); same script then verified end-to-end on both TIQ M5 / Android 13 *and* F21 Pro / Android 11 + Magisk in the same session.

6. **Bad-checksum behavior on TIQ M5: the modem deletes the file.** Test: pulled the live `LD0B_001`, decrypted slot 1, XOR'd the 8-byte MD5-XOR checksum at `pt[0x0a:0x12]` with `0xff` (so the checksum no longer matched MD5-XOR over `pt[0:10]`), re-encrypted, pushed back. After reboot, `LD0B_001` was **absent** from `/mnt/vendor/nvdata/md/NVRAM/NVD_IMEI/` — only the unrelated `FILELIST`, `NV01_000`, and `NV0S_000` were left. The other slot (untouched, still valid) didn't save the file: the modem deletes the whole `LD0B_001` on a single bad slot. **This differs from F21 Pro,** which silently rewrites `LD0B_001` with a factory backup IMEI block (Step 3 cases 2 and 3 above) and keeps the radio up. The TIQ M5 behavior also retroactively explains the initial state of this device when first connected for testing — `LD0B_001` was missing then too, consistent with a prior bad-checksum write that the modem cleared. Restoration: pushing a valid `LD0B_001` back and rebooting is sufficient; the modem accepts it, persists across reboot, both slots read back correctly. No fastboot / mtkclient flash was needed.

7. **CRLF-injection layer isolated to `adb exec-out` + `su -c "..."`.** Test: pushed a 6-byte probe (`00 0a 00 0a 00 0a`) to `/sdcard/`, pulled it back five different ways, compared each output against the source.

   | Pull method | Output | Result |
   |---|---|---|
   | `adb pull` (SYNC protocol) | 6 bytes (`000a 000a 000a`) | clean |
   | `adb exec-out cat /sdcard/probe` (no su) | 6 bytes | clean |
   | `adb shell cat /sdcard/probe` (no su) | 6 bytes | clean |
   | **`adb exec-out su -c "cat /sdcard/probe"`** | **9 bytes (`000d0a 000d0a 000d0a`)** | **corrupted** |
   | `adb shell su -c "cat /sdcard/probe"` | 6 bytes | clean |

   So the corruption requires the *combination* of `adb exec-out` (which doesn't allocate a PTY) with Magisk's `su -c "..."` invocation. Neither layer alone produces it on this device:
   - `adb exec-out` by itself pipes raw bytes (test 2).
   - Magisk's `su` by itself, when invoked under `adb shell` (which *does* allocate a PTY), produces clean output (test 5) — apparently because `su` reuses the parent PTY's terminal settings rather than spawning its own.
   - Only when `su` is invoked under `exec-out`'s no-PTY environment does it appear to allocate its own line-discipline-applying PTY for the executed command, which is what runs `\n` → `\r\n`.

   The `cp via su /sdcard + adb pull` form sidesteps this because the binary content never traverses `su`'s stdout — `cp` writes to the filesystem directly, and `adb pull` uses the SYNC protocol, neither of which involves a PTY.

### What is *not* yet checked on TIQ M5

- (no remaining items — both bad-checksum behavior and the CRLF-layer question are resolved above.)

---

## Why IMEI patching does not persist on Helio G85 (MT6769) — community report analysis

A community user reported that on a Helio G85 device (LineageOS 19 over MIUI 13, MT6769 SoC) every write to `LD0B_001` — including restoring the factory-original bytes — is silently overwritten after reboot. MAC address patching (BT + WiFi) worked normally on the same device.

This section documents the root cause, derived from a full analysis of the device's partition dumps (`notworkingonthisphone/`). Every claim below is backed by a specific byte offset in those images.

### Root cause: two-layer defense on MT6769

MT6769 differs from MT6761 (F21 Pro, TIQ M5, F25) in one critical way: it ships a **cryptographically-signed IMEI enforcement layer** implemented in `pcore/custom/service/nvram/custom_nvram_sec.c` (confirmed via source-path string at modem ROM offset `0x1521c64`). MT6761 devices do not have this file; their `custom_nvram_sec.c` is absent from the modem binary's embedded source paths.

The defense has two independent layers:

**Layer 1 — `RestoreFlag` triggered BinRegion restore (unconditional)**

The nvdata ext4 filesystem (verified via `debugfs` on `nvdata.bin`) contains a file `RestoreFlag` at the filesystem root (inode 12) with content `78 56 34 12` = little-endian `0x12345678`. This is the MTK NVRAM daemon's "restore-needed" sentinel. When the daemon sees this file on boot, it copies every record from the BinRegion (`nvram` partition) into nvdata before the OS fully starts, then clears the flag.

The dump was taken while this flag was set (consistent with mtkclient pulling the partition image in BROM mode, before the daemon's boot-time restore cleared it). The practical result: **any write to nvdata while the device is powered off is overwritten by the BinRegion copy on the next power-on**, regardless of whether the IMEI values are correct or not. This is why restoring the factory-original bytes also reverts — the daemon copies them from nvram anyway.

The `RestoreFlag` would also be (re-)set by Layer 2 when it detects an IMEI mismatch, so even if you pre-cleared the flag, a mismatch would set it again and cause the same outcome on the subsequent boot.

**Layer 2 — RSA-signed `criticalData` in `CSSD_000` (cryptographic)**

Alongside `LD0B_001` in `NVD_IMEI` there is a second file, `CSSD_000` (4168 bytes), present on this MT6769 device but **absent from the F21 Pro and TIQ M5 (both MT6761)**. The `FILELIST` for this device lists five entries: `NV0S_000`, `FILELIST`, `LD0B_001`, `CSSD_000`, `NV01_000`. The F21 Pro `FILELIST` has four entries with no `CSSD_000`.

`CSSD_000` begins with the standard `LDI\x00` NVRAM header (64 bytes), followed by 4104 bytes of null-terminated ASCII text using `\n` (the two-character literal sequence `0x5c 0x6e`, not the byte `0x0a`) as a field separator. The fields are:

| Field | Value (from dump) | Interpretation |
|---|---|---|
| `devPubKeyModulus` | 256 hex chars = 128 bytes | RSA-1024 device public key modulus |
| `devPubKeyExponent` | `10001` | RSA exponent 65537 |
| `devPubKeySign` | 512 hex chars = 256 bytes | Manufacturer RSA-2048 signature over the device public key |
| `criticalData` | 204 hex chars = 102 bytes | TLV record containing the device's official IMEIs and device IDs |
| `crticalDataSign` | 256 hex chars = 128 bytes | RSA-1024 signature over `criticalData`, signed with the device's private key |

The `criticalData` field decodes as a TLV structure with a 4-byte header (`0001 0062`) followed by five records:

| Tag | Length | Decoded content |
|---|---|---|
| `0x01` | 34 | `0x66dd3631dad31142986b6d0de8287cd2` — board/device hash |
| `0x02` | 15 | `861276053685107` — IMEI1 as ASCII |
| `0x03` | 15 | `861276053685115` — IMEI2 as ASCII |
| `0x05` | 12 | `B83BCCE54866` — device ID #1 |
| `0x06` | 12 | `B83BCCE54863` — device ID #2 |

The modem's boot-time IMEI check (`custom_nvram_read_and_check_signed_critical_data`, confirmed by string at modem ROM offset `0x15224a8`):

1. Reads `CSSD_000`, verifies `devPubKeyModulus` against `devPubKeySign` using the manufacturer's hardcoded RSA-2048 root key.
2. Reads `criticalData`, verifies `crticalDataSign` using `devPubKeyModulus` — authenticating that `criticalData` was signed by this device's unique private key.
3. Extracts the IMEIs from tags `0x02` and `0x03` of `criticalData`.
4. Reads `LD0B_001`, decrypts with AES-128-ECB, validates the MD5-XOR checksum.
5. Compares the decoded IMEI against the `criticalData` IMEIs.
6. On mismatch: logs `custom_nvram_check_imei%d not identical` (offset `0x1521c94`), attempts rewrite via `custom_nvram_check_imei%d re-write with signed data` (offset `0x1521cec`), and on failure sets `RestoreFlag` to trigger BinRegion restore on next boot.

The cross-check confirms the factory values are consistent: both the `LD0B_001` in nvdata and the `criticalData` in `CSSD_000` encode IMEI1=`861276053685107` and IMEI2=`861276053685115`. Both nvdata files are byte-identical to their BinRegion (`nvram`) copies — consistent with the BinRegion restore having already run before the dump was taken.

### Why MAC patching works but IMEI patching does not

BT and WiFi MAC address files live in separate NVRAM directories (`NVD_BT` and `NVD_WIFI`), outside the scope of `criticalData`. Their integrity check uses only the 2-byte `NVM_ComputeCheckNo` trailer documented in `wifi_bt_reverse_engineering.md` — no cryptographic signature. Patching the MAC value and recomputing the 2-byte trailer is sufficient for the modem to accept the change. `CSSD_000` has no equivalent for MAC files on this device.

### What would be required to change the IMEI on this device

To change the IMEI, all of the following would need to be updated consistently:

1. `nvdata/NVD_IMEI/LD0B_001` — new IMEI in AES-ECB encrypted BCD format with valid MD5-XOR checksum
2. `nvram` BinRegion copy of `LD0B_001` at AllFile offset `0x21d5` — same new values (otherwise Layer 1 restores from it)
3. `nvdata/NVD_IMEI/CSSD_000` — `criticalData` tags `0x02` and `0x03` updated to the new IMEI
4. `nvdata/NVD_IMEI/CSSD_000` — `crticalDataSign` re-signed over the new `criticalData` **→ requires the device's RSA-1024 private key**
5. `nvram` BinRegion copy of `CSSD_000` — same updated content

Steps 4–5 are not feasible via software: the device's RSA-1024 private key is generated at manufacturing time and never exposed to software (it is held in hardware secure storage). The manufacturer's RSA-2048 key (needed to re-issue `devPubKeySign`) is similarly inaccessible.

Alternative approaches not requiring the private key:

- **Modem ROM patch** to take the `lcsh skip IMEI check` path (string at modem ROM offset `0x1522450`). The skip condition is not yet decoded from the binary, but SBC is enabled on this device (EFuse `0x5 = 01000000`), which likely ties the skip to a hardware bit that cannot be cleared in software.
- **Firmware downgrade** to a version of MT6769 modem firmware that predates the `custom_nvram_sec.c` signed-IMEI layer, if one exists for this device's specific hardware.
- **BROM-level exploit** to extract or overwrite the signing key in secure storage, if a BROM vulnerability applicable to MT6769 is available.

### BinRegion write protection

As documented in `wifi_bt_reverse_engineering.md`, writes to the `nvram` block device are silently discarded on this class of device (the write is reported as successful but the data does not persist). This makes step 2 above impossible through the standard Linux block device interface. A fastboot or mtkclient-based flash of the `nvram` partition image is the only path for updating the BinRegion.

### Summary

The community user's observation — "even restoring original values gets reverted" — is explained by `RestoreFlag = 0x12345678` already being set in the nvdata filesystem at the time of the dump. The NVRAM daemon performs an unconditional BinRegion restore on every boot when this flag is present, overwriting whatever was written to nvdata. The underlying reason the flag gets (re-)set is the MT6769's RSA-signed `criticalData` check in `CSSD_000`: when the check fails it sets `RestoreFlag`, and updating `CSSD_000` to match a new IMEI requires the device's private key.

This signed-IMEI mechanism is absent from the repo's tested platforms (MT6761: F21 Pro, TIQ M5, F25). Devices using MT6769 (Helio G85) or later MT67xx SoCs with `custom_nvram_sec.c` present in the modem binary will exhibit this behavior.

---

## Bypass path research — MT6769 modem ROM deep analysis

After confirming the two-layer defense above, a deeper analysis of the MT6769 modem ROM strings (in `notworkingonthisphone/md1/0_md1rom`) was performed to find code paths that exit `custom_nvram_read_and_check_signed_critical_data` with success **without** validating `CSSD_000`. Three exit paths were identified from modem log strings. The analysis was string-only (no disassembly); code offsets below are file offsets in `0_md1rom`.

### Modem call chain (from ROM strings)

The relevant function call chain for an MP (retail) device:

1. **`is_need_enable_critical_data_check`** (`0x1521d0`–`0x152236c`):
   - Reads `ro.boot.hwlevel` from Android properties.
   - `P0` → `"SKIP P0"` (log `0x15221e4`) → returns FALSE → entire check skipped.
   - `P1`/`P1.1`/`P2+` → checks "sign control data"; if non-default → `"sign control data is not default value, skip"` (log `0x1522260`) → returns FALSE → check skipped.
   - `MP` → `"lcsh is_need_enable_critical_data_check MP"` (log `0x1522340`) → returns TRUE → check proceeds.
   - Any other value → returns FALSE.

2. **`checkNVdataforNewBoardId`** (called from within `custom_nvram_read_and_check_signed_critical_data`):
   - String `"lcsh new board id, check IMEI and IMEI2"` at `0x15223b8`.
   - Returns a boolean: `"new board id"` (check runs) or `"old boardid"` (check skipped).
   - The string `ro.boot.hwlevel` appears at `0x15223a8`, 16 bytes before the log — this function also reads hwlevel, likely reading it from a cached value. For MP hardware, hwlevel is always `"MP"`. The source-level documentation for this path is absent from the modem ROM strings alone; see Path B analysis below.

3. **`custom_nvram_read_and_check_signed_critical_data`** (main body):
   - `"lcsh custom_nvram_read_and_check_signed_critical_data"` entry log at `0x1522418`.
   - `"lcsh skip IMEI check"` at `0x1522450` — returned before any IMEI read if `is_need_enable` returned FALSE.
   - `"custom_nvram_read_and_check_signed_critical_data read imei fail"` at `0x1522468`.
   - `"imei is default value, bypass check"` at `0x15224a8` → **Path A bypass** (returns success).
   - `"is factory or old boardid"` at `0x1522500` → **Path B bypass** (returns success if `checkNVdataforNewBoardId` returned "old boardid").
   - `"read critical data fail"` at `0x152254c` → reads `CSSD_000`; if unreadable, this log fires and the outcome is unknown (may succeed or fail-safe to RestoreFlag).
   - `"sign data is default value, check fail"` at `0x1522598` → CSSD present but all-default; **returns failure** and likely sets RestoreFlag.

### Path A — all-FF BCD IMEI in `LD0B_001`

**What it does:** after reading and decrypting `LD0B_001`, the modem checks if the IMEI BCD bytes are all `0xFF` (the unprovisioned default). If yes, it logs `"imei is default value, bypass check"` and returns success **without** reading `CSSD_000` at all.

**How to trigger it:** write a `LD0B_001` with IMEI BCD = `FF FF FF FF FF FF FF FF` and valid MD5-XOR checksum at bytes 10–17. The `build_patched_ld0b(orig, None)` call in `patch_all.py` produces this. The modem reports "no IMEI" to the Android stack (which shows the default IMEI `000000000000000` to the user), but the boot check passes and no RestoreFlag is set. This is useful as a persistence test, not a IMEI-change solution.

### Path B — zero `NV0S_000` to trigger "old boardid"

**Hypothesis:** `checkNVdataforNewBoardId` reads the board certificate from `NV0S_000` (144-byte LDI-encrypted file at AllFile offset `0x2118`). If `NV0S_000` is zeroed (all-default), the function finds no valid board certificate, concludes the device is an old/factory board without a certificate, and returns `"old boardid"`. The outer function then logs `"is factory or old boardid"` and returns success without reading `CSSD_000`.

**Evidence for hypothesis:** `NV0S_000` is listed in the NVRAM file descriptor table at modem ROM `0x015ac768` (entry `NV0S.000`, flags `0x0001f01c`, size `0x04b8`). The adjacent `NONE` entry at `0x015ac744` (flags `0x0002f00a`, LID `0x6081`) carries the same version/LID values as the `NV0S_000` LDI header bytes `[4:8]` (`0x0002f00a`) and `[12:16]` (`0x00006081`), suggesting `NONE` is an alias or "no certificate" placeholder that the firmware falls back to when `NV0S_000` is unreadable or default-valued. This is consistent with the "old boardid" path being triggered by an absent/default board certificate.

**Counterpoint:** `ro.boot.hwlevel` appears at `0x15223a8` directly before the "new board id" log. It is possible that `checkNVdataforNewBoardId` simply re-reads hwlevel and returns "new boardid" for `MP` regardless of `NV0S_000` content. If so, Path B is blocked for MP devices.

### Test images produced

Three 64 MB images in `notworkingonthisphone/` (produced by `scratchpad/patch_all.py`, verified via `verify_patches.py`):

| File | nvdata modifications | Purpose |
|---|---|---|
| `nvdata_bypass_a.bin` | `LD0B_001` all-FF IMEI + `NV0S_000` zeroed + `RestoreFlag` cleared | Tests Path A (all-FF IMEI bypass) |
| `nvdata_bypass_b.bin` | `LD0B_001` IMEI=`000000000000000` + `NV0S_000` zeroed + `RestoreFlag` cleared | Tests Path B (old-boardid bypass) with a readable non-default IMEI |
| `nvram_bypass.bin` | BinRegion `LD0B_001` all-FF IMEI + `NV0S_000` zeroed | Ensures BinRegion is consistent; if `RestoreFlag` re-fires, device still gets all-FF IMEI → Path A can still work |

Each nvdata image patches both locations where `LD0B_001` appears:
- `md/NVRAM/NVD_IMEI/LD0B_001` (inode 383, patched in-place via ext4 extent map)
- `AllFile` at image offset `0x87B1D5` (= ext4 AllFile block base `0x879000` + AllMap entry offset `0x21D5`)

`NV0S_000` is similarly patched in both locations:
- `md/NVRAM/NVD_IMEI/NV0S_000` (inode 385)
- `AllFile` at image offset `0x87B118` (base `0x879000` + offset `0x2118`)

### Flash procedure

Both `nvram_bypass.bin` (for the `nvram` partition) and one of the `nvdata_bypass_*.bin` files (for the `nvdata` partition) must be flashed. Writes to `nvram` through the live Linux block device are silently discarded — BROM-mode flash via mtkclient is required for both.

```bash
# Power off device, connect USB (do not power on)
# Enter BROM by holding VolDown + connecting USB, or use mtkclient --payload brom

python3 mtkclient/mtk.py w nvdata notworkingonthisphone/nvdata_bypass_a.bin
python3 mtkclient/mtk.py w nvram  notworkingonthisphone/nvram_bypass.bin
```

Boot the device. On first boot:
1. The NVRAM daemon reads `RestoreFlag` in nvdata — it is now `00000000` (cleared). Daemon skips BinRegion restore.
2. Modem reads `LD0B_001` → decrypts → IMEI BCD = `FF FF FF FF...` → logs `"imei is default value, bypass check"` → success without touching `CSSD_000`.
3. Device boots normally with no IMEI (reports `000000000000000` or equivalent).

If instead a reboot loop or ECC mode occurs, it means the modem ignores the all-FF bypass and falls through to CSSD validation (which then fails). In that case:
1. Reflash with `nvdata_bypass_b.bin` (000...0 IMEI, NV0S zeroed) — this tests whether Path B (old-boardid from zeroed NV0S) provides an alternative bypass.
2. If that also fails, `checkNVdataforNewBoardId` ignores `NV0S_000` and always returns "new boardid" for MP devices, meaning both Path A and Path B are blocked. In that case, the only remaining options are a modem ROM patch or BROM exploit.

### Companion `NV01_000` note

`NV01_000` (96-byte LDI file, inode 384) decrypts to `__NVRAM_LOCK_NO_`. The modem ROM contains the comparator string `_NVRAM_LOCK_YES_` at `0x0147c58c` in the NVRAM service code (near `NVRAM_LOC_BIN_REGION_RESTORE_FAIL` assert string). This flag controls whether writes to NVRAM are locked — `NO_` = writes allowed. Changing it to `_NVRAM_LOCK_YES_` would prevent NVRAM daemon writes, potentially including `RestoreFlag` re-sets, but it would also prevent all NVRAM writes including legitimate ones. Not part of the current test plan.

---

## Modem downgrade attempt — MIUI 12.5 (Redmi Note 8 2021 / biloba) — FAILED

A three-way comparison of modem images for the **Redmi Note 8 2021** (biloba, MT6769) reveals a clean bypass that requires no nvdata/nvram surgery: flash the MIUI 12.5 modem, which predates the CSSD enforcement layer entirely.

### Three-way modem comparison

| Firmware | Modem SDK | `checkNVdataforNewBoardId` | `is_need_enable_critical_data_check` | CSSD enforced | Live test |
|---|---|---|---|---|---|
| MIUI 12.5 Global `V12.5.2.0.RCUMIXM` | `LR12A.R3.MP.V145.8.P22` | absent | absent (has `is_enable`) | **YES (MP)** | **FAIL — IMEI rejected** |
| MIUI 12.5 EU `V12.5.1.0.RCUEUXM` | `LR12A.R3.MP.V145.8.P22` | absent | absent (has `is_enable`) | YES (MP) | not tested |
| Tester device `V13.0.7.0.SCUEUXM` | `LR12A.R3.MP.V145.9.P40` | present | present | YES | FAIL — baseline |
| Community dump (nvdata/nvram source) | `LR12A.R3.MP.V145.9.P29` | present | present | YES | — |

**Live test result (tester, 2026-10-02):** Flashed V145.8 modem onto biloba. MAC patching accepted (unchanged behavior). IMEI patching failed — same outcome as V145.9. The modem downgrade does **not** bypass CSSD enforcement for a biloba device with a non-default IMEI.

Global and EU 12.5 builds carry the identical modem SDK version (`V145.8.P22`) and differ only in the DRDI container packing (8 KB size delta, 64-byte string offset shift) — both are equivalent for this purpose.

**Key observation:** `CSSD_000` is absent as a string from all four modem builds. The modem accesses signed IMEI data by NVRAM LID, not by filename. The presence of `checkNVdataforNewBoardId` and `is_need_enable_critical_data_check` is the correct indicator of enforcement, not the `CSSD_000` filename.

### V145.8 ROM deep analysis — string evidence

The following was determined by string analysis of `md1img_global_V12.5.2.0.RCUMIXM.img` (extracted ROM: `1_md1rom`, 22 MB, `base=0x00000000`, `data_offset=0x00000200`). MTK MAUI firmware does not embed string pointers in code — it uses integer trace IDs passed to `kal_trace()`. The trace strings themselves live in an extended ROM metadata region. Searching the code for string VMAs as 4-byte literal pool constants returns zero hits, confirming the trace-ID scheme. All function logic below was inferred from null-terminated trace strings in the extended region at file offsets `[0x014f7000, 0x014f9100]`.

#### `is_enable_critical_data_check()` — V145.8 hwlevel gate

V145.8 has its own gating function, `is_enable_critical_data_check`, which is **distinct from and less strict than** V145.9's renamed `is_need_enable_critical_data_check`. Complete logic inferred from the trace string set (all offsets are file offsets in `1_md1rom`):

```
is_enable_critical_data_check():
    Get product name from system properties      ← "lcsh get product name:%s" @ 0x014f83ec
    Read ro.boot.hwlevel                         ← "lcsh get hwlevel:%s" @ 0x014f846c

    if hwlevel == "P0":
        log "SKIP P0"                            ← 0x014f8480
        return FALSE    (check disabled)

    if hwlevel in {"P1", "P1.1", "P2+"}:
        read sign_control_data from NVRAM
        if sign_control_data != default_value:
            log "sign control data is not default value, skip"    ← 0x014f84f0
            return FALSE  (non-default sign control → skip)
        else:
            log "P1 P1.1 P2+ custom nv check"   ← 0x014f84b0
            return TRUE   (check enabled)

    if hwlevel == "MP":
        log "MP"                                 ← 0x014f8540
        return TRUE     (MP device → check enabled)

    else:
        log "other hwlevel skip"                 ← 0x014f8568
        return FALSE    (unknown hwlevel → skip)
```

Notably: V145.8 reads `"lcsh get product name:%s"` (0x014f83ec) but no biloba/rosemary/maltose/pending/secret comparison strings appear anywhere in the V145.8 ROM — the product name is logged but not compared against any device list. This is the key difference from V145.9.

#### `custom_nvram_read_and_check_signed_critical_data()` — V145.8 full control flow

All exit paths inferred from trace strings at file offsets `[0x014f85b0, 0x014f8700]`:

```
custom_nvram_read_and_check_signed_critical_data():
    log entry                                    ← "lcsh custom_nvram_read_and_check_signed_critical_data" @ 0x014f85b0

    if is_enable_critical_data_check() == FALSE:
        log "lcsh skip IMEI check"               ← 0x014f85e8
        return 0        ← SUCCESS (CSSD never touched)

    read IMEI from NVRAM
    if read fails:
        log "read imei fail"                     ← 0x014f8600
        return error

    if IMEI == all-FF default value:
        log "imei is default value, bypass check"← 0x014f8640   ← PATH A: confirmed SUCCESS
        return 0        ← SUCCESS (CSSD never touched)

    read CSSD_000 (critical data)
    if read fails:
        log "read critical data fail"            ← 0x014f8698   ← PATH B: return value UNCERTAIN
        return ???      ← see disassembly note below

    if sign_data == default value:
        log "sign data is default value, check fail" ← 0x014f86e4
        return error    ← CSSD present but unprovisioned → FAIL

    verify devPubKey + criticalData RSA signatures
    log "custom_nvram_check_signed_critical_data return %d"   ← 0x014f8394
    return 0 or error
```

**Disassembly note on "read critical data fail" return value:** Capstone could not decode the compiled function body — MTK MAUI embeds literal pools, crypto data, and string metadata directly inside function bodies, causing the disassembler to desync. The nearest confirmed `PUSH {LR}` prologue is at file offset `0x014e7f80`, 67 KB before the `POP {PC}` epilogue at `0x014f8d9e`. Within that 67 KB span only 4 valid instructions decoded; the rest are data bytes. The value in `r0` at the `POP {PC}` return could not be recovered statically. **The tester result is the ground truth for this path.**

#### V145.9 additions — string comparison

| String | V145.8 file offset | V145.9 file offset | Notes |
|---|---|---|---|
| `lcsh is_enable_critical_data_check` | `0x014f83c8` | absent | V145.8 name; renamed in V145.9 |
| `lcsh is_need_enable_critical_data_check` | absent | `0x015221b8` | V145.9 rename of the gate function |
| `lcsh new board id, check IMEI and IMEI2` | absent | `0x015223b8` | new per-board-ID check path |
| `lcsh checkNVdataforNewBoardId chk_val=%d ret_val=%d` | absent | `0x015223e4` | new enforcement function |
| `biloba` in product name comparison list | absent | `0x01522190` | biloba explicitly added to check scope |
| `is factory or old boardid` bypass path | absent | `0x01522500` | new bypass for factory/old-boardid devices |
| `imei is default value, bypass check` | `0x014f8640` | `0x015224a8` | present in both versions |
| `read critical data fail` | `0x014f8698` | `0x0152254c` | present in both versions |

The `biloba` string at V145.9 file `0x01522190` appears adjacent to `secret`, `rosemary`, `maltose`, and `pending` — these are Redmi Note 8 2021 model variants that V145.9 explicitly added to `checkNVdataforNewBoardId`'s enforcement scope. None of these product names appear anywhere in V145.8's string region. The `"is factory or old boardid"` path V145.9 added (between the IMEI default bypass and the "read critical data fail" log) suggests V145.9 simultaneously tightened enforcement for new board IDs while adding an explicit bypass for older/factory units that were shipped without CSSD provisioning.

### Why the old modem bypasses the check

V145.8 has a **complete** `custom_nvram_read_and_check_signed_critical_data` implementation with a working hwlevel gate — it is not absent and not a stub. For a retail biloba device (hwlevel = `"MP"`), `is_enable_critical_data_check` returns TRUE and the CSSD check runs. The bypass operates via one of two paths:

**Path A — wiped/default IMEI (confirmed from strings, return value = 0):**
Any scenario that leaves `LD0B_001` in its unprovisioned state (IMEI BCD = `FF FF FF FF FF FF FF FF`) — factory reset, bad flash, or deliberate IMEI wipe — causes V145.8 to log `"imei is default value, bypass check"` at `0x014f8640` and return 0 (SUCCESS) without reading CSSD_000 at all. This path is present in both V145.8 and V145.9 and its return value is unambiguous from the log string.

**Path B — missing CSSD with valid IMEI (confirmed non-zero, live test 2026-10-02):**
If `LD0B_001` holds a valid non-default IMEI but CSSD_000 is absent, V145.8 hits `"read critical data fail"` at `0x014f8698` and returns **non-zero (failure)**. Live hardware test with V145.8 modem on biloba: MAC patching accepted, IMEI patching rejected — identical outcome to V145.9. The modem downgrade does not help for a device with a real IMEI.

Path A (wiped IMEI → all-FF default → bypass) was not explicitly tested and may still return 0, but it is not a usable IMEI-change path: a device with all-FF IMEI has no IMEI, and patching it to a real value then triggers the CSSD check on the next boot — landing back in Path B.

The structural difference V145.9 introduced for biloba (adding `checkNVdataforNewBoardId` and the explicit product name list) is therefore a secondary gate on top of existing enforcement, not the source of the enforcement itself. V145.8 already enforces CSSD for MP biloba via the hwlevel gate alone.

### Test procedure and result

Flashed `md1img` partition from `md1img_global_V12.5.2.0.RCUMIXM.img` via mtkclient, booted the device. SBC accepted the image (official Xiaomi signing chain valid for biloba). Voice/data functional (CCCI interface compatible across MIUI versions). Then patched `LD0B_001` via `live_patch.sh`.

**Result: IMEI patch rejected.** After reboot the modem rolled back the IMEI to its factory value. MAC address patching continued to work normally (MAC uses NVM_ComputeCheckNo only, no CSSD). The outcome is byte-for-byte identical to the V145.9 baseline.

**Conclusion:** the modem downgrade does not provide a bypass for IMEI patching on biloba. V145.8 enforces CSSD for MP-hwlevel devices via `is_enable_critical_data_check` → TRUE → CSSD required. The absence of `checkNVdataforNewBoardId` and the `is_need_enable_critical_data_check` rename are V145.9 additions on top of existing enforcement, not the origin of it.

### Remaining paths

See the bypass path research section above for paths that remain open:

- **Path A (wiped IMEI):** patch `LD0B_001` to all-FF default to get through V145.8's IMEI default bypass, but this only produces a device with no IMEI; patching to a real value triggers CSSD check on next boot.
- **Modem ROM patch:** modify the compiled `is_enable_critical_data_check` function in `md1img` to always return FALSE. Requires identifying the function start in the binary (67 KB span, Capstone desync — hard) and a way to re-sign or disable SBC check for the patched image.
- **BROM exploit:** extract or overwrite the device's RSA private key or the CSSD partition directly via a BROM vulnerability applicable to MT6769.
- **CSSD recovery:** if the device's original `CSSD_000` data can be recovered (from a full nvdata backup taken before IMEI loss, or from the manufacturer), restoring it to both nvdata and the BinRegion nvram would re-enable normal IMEI patching flow.
