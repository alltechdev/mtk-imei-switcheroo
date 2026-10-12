# Exact biloba firmware edits

All offsets below are **file offsets**, unless explicitly marked ROM/runtime.
See [fingerprints](artifacts.md) before identifying any image by filename.

## Modem

| Version | Gate ROM offset | Full-image offset | Original bytes | Replacement |
| --- | --- | --- | --- | --- |
| V12.5.2.0.RCUMIXM | `0x012eb880` | `0x012eba80` | `cf 64 20 6e 0c 04` | `00 6a a0 e8 00 65` |
| V14.0.4.0.TCUMIXM | `0x01316320` | `0x01316520` | `f0 64 20 6e 0c 04` | `00 6a a0 e8 00 65` |

The executable uses MIPS16. The replacement is `li v0,0; jrc ra; nop`:
return before the original stack-frame allocation. The NOP is padding, not a
return delay slot. The extracted ROM excludes the first 512-byte header;
full-image offset = ROM offset + `0x200`. In the identified region, runtime
address = ROM offset + `0x90000000`.

The V12 gate's name-bearing log string identifies `is_enable_critical_data_check`.
V14 uses `is_need_enable_critical_data_check`. Both were identified through
string references and decoded control flow, not debug symbols.

| Evidence | V12 ROM offset | V14 ROM offset |
| --- | --- | --- |
| `ro.boot.hwlevel` string | `0x014f85a0` | `0x0152f5c4` |
| Pointer to that string | `0x012eb9d4` | `0x0131649c` |
| Caller entry | `0x012eba08` | `0x01316524` |
| Call to gate | `0x012eba2e` | `0x0131654a` |
| Branch on nonzero result | `0x012eba34` | `0x01316550` |

In each caller, zero takes cleanup/the skip path and returns success (1).
The unpatched V12 gate also compares product names including biloba. Earlier
claims that product comparisons or code references were absent were incorrect;
searching for zero-based pointers missed the `0x90000000` runtime alias.

## LK

| LK input | md1img policy entry | Changed byte | Change |
| --- | --- | --- | --- |
| Supplied 4 MiB partition dump | `0x0012225c` | `0x00122273` | `02` → `00` |
| V14 packaged image | `0x001220f0` | `0x00122107` | `02` → `00` |

The four policy bytes change from `01 00 03 02` to `01 00 03 00`.
Their order is secure-boot-disabled locked/unlocked, then secure-boot-enabled
locked/unlocked. Bit 1 controls verification. Only the last state changes;
locked verification and all other partition policies remain intact.

The V12 modem patch was paired with the supplied LK dump, whose MIUI provenance
is not independently established. It should not be described as a V12 stock LK.
The V14 pair uses the LK member from the same supplied V14 firmware ZIP.

## Why the second edit matters

Original LK requires modem authentication even when unlocked. The changed
modem payload mismatches its signed digest. The policy edit makes LK's AP-side
payload verifier skip that check under the unlocked policy.

Both inspected preloaders have LK policy `01 00 03 00` at file `0x4bef4`:
they skip LK certificate and payload checks when the unlocked state is accepted.
This is why changing LK does not necessarily require re-signing it.

LK's certificate wrapper can still run if modem secure-boot flags require it.
The LTE flag is read from `0x11ce04a0`, bit 1; its value was absent from the saved
indexed eFuse capture. These edits do not change hardware fuses or prove that
every downstream verifier accepts the modified modem.
