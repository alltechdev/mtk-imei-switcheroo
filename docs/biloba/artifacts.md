# Biloba firmware fingerprints

SHA-256 identifies complete files. These files and the standalone patchers
were supplied separately; they are not included in this repository.

## V12 modem and supplied LK dump

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| Original modem: `md1img_global_V12.5.2.0.RCUMIXM.img` | 57,155,584 | `1dd3043e889356bd5edb9343a96fe3122dc0fae7245047e815f695902a6002ab` |
| Patched modem: `md1img_global_V12.5.2.0.RCUMIXM.return_zero.img` | 57,155,584 | `c449b5b701e1b376c85d04df4e7a0a3f2fab9b3afc590345b6c38176a42763e6` |
| Original LK dump: `lk_a,b.bin` | 4,194,304 | `cef141e957d7300ab936b030de0aad2999b2a947ff502e4b455480d93f487028` |
| Patched LK: `lk.md1img_unlocked_noverify.bin` | 4,194,304 | `b3fab4a083cd4955b7c8a8a83bc7b2d5f562d66ef6542c449952369c2f36843f` |

## V14.0.4.0.TCUMIXM

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| Original modem ZIP member: `md1img.img` | 57,536,512 | `4077b7aa2b0d7eb1f0c51cde274fb2053e90e66e64134765410a74d1d01442fc` |
| Patched modem: `md1img_V14.0.4.0.TCUMIXM.return_zero.img` | 57,536,512 | `91a02126306d9eaa606eec9e85da7ef73fe4b23b7c2de141131d014f95dbda3a` |
| Original LK ZIP member: `lk.img` | 1,605,632 | `d0f4b13c75693e5583bc77f6acccdcd40337b88f47226e7272dfb7d1a35f9bb0` |
| Patched LK: `lk_V14.0.4.0.TCUMIXM.md1img_unlocked_noverify.img` | 1,605,632 | `2ff4e224db4984bbc8468cbced5fde8d75497035a715ea7aa1ca205febb3d19d` |

V14 source ZIP: `fw_biloba_miui_BILOBAGlobal_V14.0.4.0.TCUMIXM_bf1ba493fe_13.0.zip`,
SHA-256 `a70288fac0d174ff0a32230ee242da4319124f48c923cb2a079662d3185f9e91`.
Original members are `firmware-update/md1img.img` and `firmware-update/lk.img`.

The V14 LK is a packaged image; the older LK input is a full 4 MiB partition
dump. Different lengths are expected; each patch retains its own input size.

## Extracted modem members

These are raw executable members, not complete modem flash images:

| Version | Bytes | Original ROM SHA-256 |
| --- | ---: | --- |
| V12 | 22,637,476 | `5e6275c4047817b6c35eaa74d83937d46604cb7109a197e8f7a6926f434e7df2` |
| V14 | 22,866,916 | `e995962784a380248d6d6129cad494b7033be97c7720eb02f304b088fbcfa39b` |

## Preloaders inspected, not patched

- Supplied `preloader.emmc.boot1,2.bin`:
  `165cb58913f342e2b445d35e8e3e526ecd674b622b410e23d83a780ee64f1c99`.
- V14 ZIP member `firmware-update/preloader.img`:
  `e961d577c6ed255426a820535b04f157a4726277f5700f8cb9f7c80e8e405c1b`.

See [status](README.md), [exact edits](patches.md), and [script usage](patchers.md).
