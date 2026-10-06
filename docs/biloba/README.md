# Biloba modem/LK investigation

Updated 2026-10-06. Device: Redmi Note 8 2021 (biloba, Helio G85).
This is separate from the repository's LD0B and MAC editing tools.

## Status by version

| Configuration | Evidence |
| --- | --- |
| Original V12.5.2.0.RCUMIXM modem | Reported working; stock downgrade alone did not solve IMEI rejection |
| V12 modem-only return-zero patch | Tester reported bootloop before launcher |
| V12 patched modem + patched supplied LK | Tester subsequently reported the pair worked |
| V14.0.4.0.TCUMIXM patched modem + bundled LK | Offline checks passed; not boot-tested |

The paired V12 success is a user-relayed tester result. We do not have an
independent capture demonstrating radio service, each IMEI slot, or persistence
over repeated reboots. Do not expand that report into those additional claims.

## What changed

Each pair has six changed modem bytes and one changed LK byte. The modem gate
returns zero, so its caller skips the signed critical-data/IMEI check and returns
success. LK's modem-verification policy is disabled for the secure-boot-enabled,
unlocked state. No IMEI values, preloader code or certificate/signature bytes
are edited by these patchers. Each output retains its own original size.

The supplied preloader permits modified LK through its certificate/payload
checks when it accepts an unlocked state. An unlocked header alone is not
proof of authenticated state. Hardware modem authentication remains a separate
condition; changing LK is not a universal secure-boot bypass.

## Topics

- [Exact code changes and authentication path](patches.md)
- [Input/output fingerprints](artifacts.md)
- [Verification and remaining limits](verification.md)
- [Standalone script usage](patchers.md)

These findings came from supplied binaries, disassembly, isolated execution
tests and the tester's report. No matching vendor signing key was identified
in either supplied key archive. The signatures were retained, not repaired.

The investigation process can be reused on related devices, but function
identity, code, authentication policy and hardware behavior must be established
again for each firmware. Neither offsets nor images transfer based on SoC alone.
