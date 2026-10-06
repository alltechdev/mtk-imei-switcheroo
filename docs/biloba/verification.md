# Biloba verification

See [status](README.md) for the distinction between the reported working V12
pair and V14's offline-only result.

## Offline checks

For both versions, input fingerprints and target bytes were checked before
editing copies. Output lengths match inputs. Exactly six modem bytes and one
LK byte differ; all other bytes, including certificate/signature data, match.
Patchers reject unsupported firmware, existing outputs and in-place writes.

The MIPS execution tests run the patched gate and original caller with
allocator/free/logger stubs. The caller returns success (1), preserving its
stack and saved register. A deliberately wrong expected result fails as intended.
The older patch also has a separate stub return-value/stack test.

Each version passed 15 ARM execution cases using actual LK/preloader code:

- Original LK, patched LK and preloader policy getters across secure boot
  on/off and locked/unlocked states: 12 cases.
- Original LK reaches the authentication endpoint under secure/unlocked state.
- Patched LK skips that endpoint under the same state.
- Patched LK still reaches authentication when locked.

State providers, logging, timer and the authentication endpoint are mocked.
The endpoint is a sentinel exit proving call reachability, not simulated
successful cryptography. LTE/C2K flags are clear in the verifier-path tests.
These tests establish control flow, not full boot or live hardware state.

Original modem certificate signatures were checked against their embedded
public keys. Both patched ROM digests differ from the signed values. Neither
`keys.zip` nor the inspected `bootloader.zip` supplied a matching signing key.

## Remaining limits

The saved seccfg header reports unlocked, but its authentication was not proven
offline. Neither the plain digest nor the known software-AES digest method
validated it; hardware-backed methods remain untested. This does not establish
that seccfg is invalid. Preloader can fall back to locked when state is unavailable.

The old pair's reported success does not establish a V14 result, compatibility
with another device, or long-term radio/IMEI persistence. Those require device
testing. No device was flashed by the analysis scripts or execution harnesses.

The analysis fixtures and full reproduction runner remain in the separate
research workspace; they are not shipped in this repository. The standalone
patchers were supplied separately. See [script usage](patchers.md).
