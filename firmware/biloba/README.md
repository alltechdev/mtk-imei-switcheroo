# Biloba firmware patchers

| Directory | Exact supported inputs | Device result |
| --- | --- | --- |
| [v12](v12) | V12.5.2.0.RCUMIXM modem + supplied 4 MiB LK dump | Paired patch reported working |
| [v14](v14) | V14.0.4.0.TCUMIXM packaged modem + LK | Offline verification only |

Each directory contains two standalone Python patchers and a `profile.json`
with exact input/output fingerprints. Patchers use the standard library and
can be attached individually. Keep the V14 identifiers in their filenames.

- [Patch two files](../../docs/biloba/patchers.md)
- [Reproduce extraction and all offline checks](../../docs/biloba/reproduce.md)
- [Changes and limitations](../../docs/biloba/README.md)

`reproduce.py` uses the profiles and the repository's research helpers. It
requires the repository checkout, Python 3.11+, the packages in
`requirements.txt`, and `qemu-user-static`. Firmware inputs are supplied locally.
