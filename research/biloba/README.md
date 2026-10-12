# Biloba research tools and evidence

Patchers live in [firmware/biloba](../../firmware/biloba/README.md).
The [reproduction guide](../../docs/biloba/reproduce.md) runs these helpers with
explicit inputs; none depends on the original research workspace.

| Location | Contents |
| --- | --- |
| `v12/`, `v14/` | MIPS caller and ARM LK/preloader execution harnesses |
| `v12/evidence/`, `v14/evidence/` | Saved gate/caller/authentication disassembly and execution results |
| `tools/mips16_subset.py` | Decoder for the MIPS16 instructions used by these functions |
| `tools/check_signing_keys.py` | Optional supplied-key compatibility and modem-signature audit |
| `tools/check_bootloader_archive.py` | Optional bootloader source archive public-key comparison |
| `tools/check_seccfg_offline.py` | Plain/software-AES saved-state digest checks |

Evidence records the original investigation. Fresh execution results are written
to the selected run directory, alongside generated ELF fixtures and logs.
Harnesses mock external state providers and authentication endpoints; they prove
control flow, not a complete device boot. See [verification limits](../../docs/biloba/verification.md).

Firmware images, private keys, archives, generated binaries and duplicate builds
are excluded. The decoder is a targeted research helper, not a general MIPS
disassembler. The seccfg helper does not test hardware-backed authentication.
