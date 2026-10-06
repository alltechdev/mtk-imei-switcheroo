; Supplied LK only. Columns: file offset, runtime address, bytes, instruction.
; Function names inferred from matching supplied source/library code.

; get_sec_policy
000179ec  4c4177ec  70b5       push {r4, r5, r6, lr}
000179ee  4c4177ee  82b0       sub sp, #8
000179f0  4c4177f0  274d       ldr r5, [pc, #0x9c]
000179f2  4c4177f2  0024       movs r4, #0
000179f4  4c4177f4  0646       mov r6, r0
000179f6  4c4177f6  6846       mov r0, sp
000179f8  4c4177f8  0094       str r4, [sp]
000179fa  4c4177fa  0194       str r4, [sp, #4]
000179fc  4c4177fc  7d44       add r5, pc
000179fe  4c4177fe  54f0f7ff   bl #0x4c46c7f0
00017a02  4c417802  00b1       cbz r0, #0x4c417806
00017a04  4c417804  0094       str r4, [sp]
00017a06  4c417806  01a8       add r0, sp, #4
00017a08  4c417808  0ef08cf9   bl #0x4c425b24
00017a0c  4c41780c  019b       ldr r3, [sp, #4]
00017a0e  4c41780e  5a1e       subs r2, r3, #1
00017a10  4c417810  012a       cmp r2, #1
00017a12  4c417812  30d9       bls #0x4c417876
00017a14  4c417814  033b       subs r3, #3
00017a16  4c417816  012b       cmp r3, #1
00017a18  4c417818  01d9       bls #0x4c41781e
00017a1a  4c41781a  0423       movs r3, #4
00017a1c  4c41781c  0193       str r3, [sp, #4]
00017a1e  4c41781e  1d48       ldr r0, [pc, #0x74]
00017a20  4c417820  0099       ldr r1, [sp]
00017a22  4c417822  7844       add r0, pc
00017a24  4c417824  27f0aafe   bl #0x4c43f57c
00017a28  4c417828  1b48       ldr r0, [pc, #0x6c]
00017a2a  4c41782a  0199       ldr r1, [sp, #4]
00017a2c  4c41782c  7844       add r0, pc
00017a2e  4c41782e  27f0a5fe   bl #0x4c43f57c
00017a32  4c417832  009b       ldr r3, [sp]
00017a34  4c417834  6bb9       cbnz r3, #0x4c417852
00017a36  4c417836  019b       ldr r3, [sp, #4]
00017a38  4c417838  184a       ldr r2, [pc, #0x60]
00017a3a  4c41783a  032b       cmp r3, #3
00017a3c  4c41783c  4fea4613   lsl.w r3, r6, #5
00017a40  4c417840  a3eb8606   sub.w r6, r3, r6, lsl #2
00017a44  4c417844  ab58       ldr r3, [r5, r2]
00017a46  4c417846  1e44       add r6, r3
00017a48  4c417848  0cbf       ite eq
00017a4a  4c41784a  707d       ldrbeq r0, [r6, #0x15]
00017a4c  4c41784c  307d       ldrbne r0, [r6, #0x14]
00017a4e  4c41784e  02b0       add sp, #8
00017a50  4c417850  70bd       pop {r4, r5, r6, pc}
00017a52  4c417852  012b       cmp r3, #1
00017a54  4c417854  18bf       it ne
00017a56  4c417856  0020       movne r0, #0
00017a58  4c417858  f9d1       bne #0x4c41784e
00017a5a  4c41785a  019b       ldr r3, [sp, #4]
00017a5c  4c41785c  0f4a       ldr r2, [pc, #0x3c]
00017a5e  4c41785e  032b       cmp r3, #3
00017a60  4c417860  4fea4613   lsl.w r3, r6, #5
00017a64  4c417864  a3eb8606   sub.w r6, r3, r6, lsl #2
00017a68  4c417868  ab58       ldr r3, [r5, r2]
00017a6a  4c41786a  1e44       add r6, r3
00017a6c  4c41786c  0cbf       ite eq
00017a6e  4c41786e  f07d       ldrbeq r0, [r6, #0x17]
00017a70  4c417870  b07d       ldrbne r0, [r6, #0x16]
00017a72  4c417872  02b0       add sp, #8
00017a74  4c417874  70bd       pop {r4, r5, r6, pc}
00017a76  4c417876  0a48       ldr r0, [pc, #0x28]
00017a78  4c417878  0423       movs r3, #4
00017a7a  4c41787a  0099       ldr r1, [sp]
00017a7c  4c41787c  0193       str r3, [sp, #4]
00017a7e  4c41787e  7844       add r0, pc
00017a80  4c417880  27f07cfe   bl #0x4c43f57c
00017a84  4c417884  0748       ldr r0, [pc, #0x1c]
00017a86  4c417886  0199       ldr r1, [sp, #4]
00017a88  4c417888  7844       add r0, pc
00017a8a  4c41788a  27f077fe   bl #0x4c43f57c

; get_vfy_policy
00017b20  4c417920  08b5       push {r3, lr}
00017b22  4c417922  fff763ff   bl #0x4c4177ec
00017b26  4c417926  c0f34000   ubfx r0, r0, #1, #1
00017b2a  4c41792a  08bd       pop {r3, pc}

; modem_image_auth
00055df8  4c455bf8  2de9f043   push.w {r4, r5, r6, r7, r8, sb, lr}
00055dfc  4c455bfc  0c46       mov r4, r1
00055dfe  4c455bfe  0146       mov r1, r0
00055e00  4c455c00  4348       ldr r0, [pc, #0x10c]
00055e02  4c455c02  83b0       sub sp, #0xc
00055e04  4c455c04  1546       mov r5, r2
00055e06  4c455c06  0093       str r3, [sp]
00055e08  4c455c08  1e46       mov r6, r3
00055e0a  4c455c0a  2246       mov r2, r4
00055e0c  4c455c0c  2b46       mov r3, r5
00055e0e  4c455c0e  7844       add r0, pc
00055e10  4c455c10  f146       mov sb, lr
00055e12  4c455c12  e9f7b3fc   bl #0x4c43f57c
00055e16  4c455c16  3f4b       ldr r3, [pc, #0xfc]
00055e18  4c455c18  7b44       add r3, pc
00055e1a  4c455c1a  1b68       ldr r3, [r3]
00055e1c  4c455c1c  4bb3       cbz r3, #0x4c455c72
00055e1e  4c455c1e  3e4f       ldr r7, [pc, #0xf8]
00055e20  4c455c20  0123       movs r3, #1
00055e22  4c455c22  3e49       ldr r1, [pc, #0xf8]
00055e24  4c455c24  2046       mov r0, r4
00055e26  4c455c26  0722       movs r2, #7
00055e28  4c455c28  7f44       add r7, pc
00055e2a  4c455c2a  7944       add r1, pc
00055e2c  4c455c2c  3b60       str r3, [r7]
00055e2e  4c455c2e  eaf7cdfd   bl #0x4c4407cc
00055e32  4c455c32  8046       mov r8, r0
00055e34  4c455c34  00bb       cbnz r0, #0x4c455c78
00055e36  4c455c36  3a4b       ldr r3, [pc, #0xe8]
00055e38  4c455c38  7b44       add r3, pc
00055e3a  4c455c3a  1b68       ldr r3, [r3]
00055e3c  4c455c3c  012b       cmp r3, #1
00055e3e  4c455c3e  3fd0       beq #0x4c455cc0
00055e40  4c455c40  3848       ldr r0, [pc, #0xe0]
00055e42  4c455c42  7844       add r0, pc
00055e44  4c455c44  e9f79afc   bl #0x4c43f57c
00055e48  4c455c48  3749       ldr r1, [pc, #0xdc]
00055e4a  4c455c4a  2046       mov r0, r4
00055e4c  4c455c4c  0722       movs r2, #7
00055e4e  4c455c4e  7944       add r1, pc
00055e50  4c455c50  eaf7bcfd   bl #0x4c4407cc
00055e54  4c455c54  40b9       cbnz r0, #0x4c455c68
00055e56  4c455c56  354b       ldr r3, [pc, #0xd4]
00055e58  4c455c58  7b44       add r3, pc
00055e5a  4c455c5a  1b68       ldr r3, [r3]
00055e5c  4c455c5c  012b       cmp r3, #1
00055e5e  4c455c5e  3ed0       beq #0x4c455cde
00055e60  4c455c60  3348       ldr r0, [pc, #0xcc]
00055e62  4c455c62  7844       add r0, pc
00055e64  4c455c64  e9f78afc   bl #0x4c43f57c
00055e68  4c455c68  324b       ldr r3, [pc, #0xc8]
00055e6a  4c455c6a  7b44       add r3, pc
00055e6c  4c455c6c  1b68       ldr r3, [r3]
00055e6e  4c455c6e  012b       cmp r3, #1
00055e70  4c455c70  0ad0       beq #0x4c455c88
00055e72  4c455c72  03b0       add sp, #0xc
00055e74  4c455c74  bde8f083   pop.w {r4, r5, r6, r7, r8, sb, pc}
00055e78  4c455c78  2f49       ldr r1, [pc, #0xbc]
00055e7a  4c455c7a  2046       mov r0, r4
00055e7c  4c455c7c  0722       movs r2, #7
00055e7e  4c455c7e  7944       add r1, pc
00055e80  4c455c80  eaf7a4fd   bl #0x4c4407cc
00055e84  4c455c84  0028       cmp r0, #0
00055e86  4c455c86  e6d0       beq #0x4c455c56
00055e88  4c455c88  2c4f       ldr r7, [pc, #0xb0]
00055e8a  4c455c8a  0020       movs r0, #0
00055e8c  4c455c8c  08f0f8f8   bl #0x4c45de80
00055e90  4c455c90  3146       mov r1, r6
00055e92  4c455c92  7f44       add r7, pc
00055e94  4c455c94  3860       str r0, [r7]
00055e96  4c455c96  2846       mov r0, r5
00055e98  4c455c98  17f006f8   bl #0x4c46cca8
00055e9c  4c455c9c  0146       mov r1, r0
00055e9e  4c455c9e  38bb       cbnz r0, #0x4c455cf0
00055ea0  4c455ca0  2748       ldr r0, [pc, #0x9c]
00055ea2  4c455ca2  7844       add r0, pc
00055ea4  4c455ca4  e9f76afc   bl #0x4c43f57c
00055ea8  4c455ca8  3868       ldr r0, [r7]
00055eaa  4c455caa  08f0e9f8   bl #0x4c45de80
00055eae  4c455cae  0246       mov r2, r0
00055eb0  4c455cb0  2448       ldr r0, [pc, #0x90]
00055eb2  4c455cb2  2146       mov r1, r4
00055eb4  4c455cb4  7844       add r0, pc
00055eb6  4c455cb6  03b0       add sp, #0xc
00055eb8  4c455cb8  bde8f043   pop.w {r4, r5, r6, r7, r8, sb, lr}
00055ebc  4c455cbc  e9f75ebc   b.w #0x4c43f57c
00055ec0  4c455cc0  2148       ldr r0, [pc, #0x84]
00055ec2  4c455cc2  7844       add r0, pc
00055ec4  4c455cc4  e9f75afc   bl #0x4c43f57c
00055ec8  4c455cc8  2049       ldr r1, [pc, #0x80]
00055eca  4c455cca  2046       mov r0, r4
00055ecc  4c455ccc  0722       movs r2, #7
00055ece  4c455cce  c7f80080   str.w r8, [r7]
00055ed2  4c455cd2  7944       add r1, pc
00055ed4  4c455cd4  eaf77afd   bl #0x4c4407cc
00055ed8  4c455cd8  0028       cmp r0, #0
00055eda  4c455cda  cad1       bne #0x4c455c72
00055edc  4c455cdc  bbe7       b #0x4c455c56
00055ede  4c455cde  1c48       ldr r0, [pc, #0x70]
00055ee0  4c455ce0  7844       add r0, pc
00055ee2  4c455ce2  e9f74bfc   bl #0x4c43f57c
00055ee6  4c455ce6  1b4b       ldr r3, [pc, #0x6c]
00055ee8  4c455ce8  0022       movs r2, #0
00055eea  4c455cea  7b44       add r3, pc
00055eec  4c455cec  1a60       str r2, [r3]
00055eee  4c455cee  c0e7       b #0x4c455c72
00055ef0  4c455cf0  1948       ldr r0, [pc, #0x64]
00055ef2  4c455cf2  1a4c       ldr r4, [pc, #0x68]
00055ef4  4c455cf4  7844       add r0, pc
00055ef6  4c455cf6  e9f741fc   bl #0x4c43f57c
00055efa  4c455cfa  1949       ldr r1, [pc, #0x64]
00055efc  4c455cfc  7c44       add r4, pc
00055efe  4c455cfe  194a       ldr r2, [pc, #0x64]
00055f00  4c455d00  4846       mov r0, sb
00055f02  4c455d02  c423       movs r3, #0xc4
00055f04  4c455d04  0094       str r4, [sp]
00055f06  4c455d06  7944       add r1, pc
00055f08  4c455d08  7a44       add r2, pc
00055f0a  4c455d0a  e9f7e1fc   bl #0x4c43f6d0

; seclib_sec_boot_enabled
0006c920  4c46c720  284b       ldr r3, [pc, #0xa0]
0006c922  4c46c722  7b44       add r3, pc
0006c924  4c46c724  1b68       ldr r3, [r3]
0006c926  4c46c726  1b68       ldr r3, [r3]
0006c928  4c46c728  112b       cmp r3, #0x11
0006c92a  4c46c72a  2cd0       beq #0x4c46c786
0006c92c  4c46c72c  222b       cmp r3, #0x22
0006c92e  4c46c72e  30b5       push {r4, r5, lr}
0006c930  4c46c730  0446       mov r4, r0
0006c932  4c46c732  83b0       sub sp, #0xc
0006c934  4c46c734  7546       mov r5, lr
0006c936  4c46c736  1cd0       beq #0x4c46c772
0006c938  4c46c738  c3b1       cbz r3, #0x4c46c76c
0006c93a  4c46c73a  b8f775fe   bl #0x4c425428
0006c93e  4c46c73e  28bb       cbnz r0, #0x4c46c78c
0006c940  4c46c740  214c       ldr r4, [pc, #0x84]
0006c942  4c46c742  2846       mov r0, r5
0006c944  4c46c744  2149       ldr r1, [pc, #0x84]
0006c946  4c46c746  8123       movs r3, #0x81
0006c948  4c46c748  214a       ldr r2, [pc, #0x84]
0006c94a  4c46c74a  7c44       add r4, pc
0006c94c  4c46c74c  7944       add r1, pc
0006c94e  4c46c74e  0094       str r4, [sp]
0006c950  4c46c750  7a44       add r2, pc
0006c952  4c46c752  d2f7bdff   bl #0x4c43f6d0
0006c956  4c46c756  b8f767fe   bl #0x4c425428
0006c95a  4c46c75a  0228       cmp r0, #2
0006c95c  4c46c75c  24d9       bls #0x4c46c7a8
0006c95e  4c46c75e  1d48       ldr r0, [pc, #0x74]
0006c960  4c46c760  1d49       ldr r1, [pc, #0x74]
0006c962  4c46c762  7844       add r0, pc
0006c964  4c46c764  7944       add r1, pc
0006c966  4c46c766  d2f709ff   bl #0x4c43f57c
0006c96a  4c46c76a  2346       mov r3, r4
0006c96c  4c46c76c  1846       mov r0, r3
0006c96e  4c46c76e  03b0       add sp, #0xc
0006c970  4c46c770  30bd       pop {r4, r5, pc}
0006c972  4c46c772  07f0a5fc   bl #0x4c4740c0
0006c976  4c46c776  0128       cmp r0, #1
0006c978  4c46c778  14d0       beq #0x4c46c7a4
0006c97a  4c46c77a  012c       cmp r4, #1
0006c97c  4c46c77c  16d0       beq #0x4c46c7ac
0006c97e  4c46c77e  0023       movs r3, #0
0006c980  4c46c780  1846       mov r0, r3
0006c982  4c46c782  03b0       add sp, #0xc
0006c984  4c46c784  30bd       pop {r4, r5, pc}
0006c986  4c46c786  0123       movs r3, #1
0006c988  4c46c788  1846       mov r0, r3
0006c98a  4c46c78a  7047       bx lr
0006c98c  4c46c78c  134b       ldr r3, [pc, #0x4c]
0006c98e  4c46c78e  1448       ldr r0, [pc, #0x50]
0006c990  4c46c790  1449       ldr r1, [pc, #0x50]
0006c992  4c46c792  7b44       add r3, pc
0006c994  4c46c794  1b68       ldr r3, [r3]
0006c996  4c46c796  d3f8e820   ldr.w r2, [r3, #0xe8]
0006c99a  4c46c79a  7844       add r0, pc
0006c99c  4c46c79c  7944       add r1, pc
0006c99e  4c46c79e  d2f7edfe   bl #0x4c43f57c
0006c9a2  4c46c7a2  cde7       b #0x4c46c740
0006c9a4  4c46c7a4  012c       cmp r4, #1
0006c9a6  4c46c7a6  d6d0       beq #0x4c46c756
0006c9a8  4c46c7a8  0123       movs r3, #1
0006c9aa  4c46c7aa  dfe7       b #0x4c46c76c
0006c9ac  4c46c7ac  b8f73cfe   bl #0x4c425428
0006c9b0  4c46c7b0  0228       cmp r0, #2
0006c9b2  4c46c7b2  e4d9       bls #0x4c46c77e
0006c9b4  4c46c7b4  0c48       ldr r0, [pc, #0x30]
0006c9b6  4c46c7b6  0d49       ldr r1, [pc, #0x34]
0006c9b8  4c46c7b8  7844       add r0, pc
0006c9ba  4c46c7ba  7944       add r1, pc
0006c9bc  4c46c7bc  d2f7defe   bl #0x4c43f57c
0006c9c0  4c46c7c0  dde7       b #0x4c46c77e

; get_sboot_state
0006c9f0  4c46c7f0  10b5       push {r4, lr}
0006c9f2  4c46c7f2  0446       mov r4, r0
0006c9f4  4c46c7f4  0120       movs r0, #1
0006c9f6  4c46c7f6  fff793ff   bl #0x4c46c720
0006c9fa  4c46c7fa  2060       str r0, [r4]
0006c9fc  4c46c7fc  0020       movs r0, #0
0006c9fe  4c46c7fe  10bd       pop {r4, pc}

; efuse_sbc_enabled
000742c0  4c4740c0  6023       movs r3, #0x60
000742c2  4c4740c2  c1f2ce13   movt r3, #0x11ce
000742c6  4c4740c6  1868       ldr r0, [r3]
000742c8  4c4740c8  c0f34000   ubfx r0, r0, #1, #1
000742cc  4c4740cc  7047       bx lr

; sec_md_sbcen_init
00074e7c  4c474c7c  094b       ldr r3, [pc, #0x24]
00074e7e  4c474c7e  4ff49461   mov.w r1, #0x4a0
00074e82  4c474c82  094a       ldr r2, [pc, #0x24]
00074e84  4c474c84  0020       movs r0, #0
00074e86  4c474c86  c1f2ce11   movt r1, #0x11ce
00074e8a  4c474c8a  7b44       add r3, pc
00074e8c  4c474c8c  1b68       ldr r3, [r3]
00074e8e  4c474c8e  7a44       add r2, pc
00074e90  4c474c90  1268       ldr r2, [r2]
00074e92  4c474c92  1870       strb r0, [r3]
00074e94  4c474c94  1070       strb r0, [r2]
00074e96  4c474c96  0020       movs r0, #0
00074e98  4c474c98  0a68       ldr r2, [r1]
00074e9a  4c474c9a  9207       lsls r2, r2, #0x1e
00074e9c  4c474c9c  44bf       itt mi
00074e9e  4c474c9e  0122       movmi r2, #1
00074ea0  4c474ca0  1a70       strbmi r2, [r3]
00074ea2  4c474ca2  7047       bx lr
