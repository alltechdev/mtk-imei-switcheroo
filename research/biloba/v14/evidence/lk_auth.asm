; Columns: file offset, runtime address, bytes, instruction.

; Region 0x179f8
000179f8 4c4177f8 70b5       push {r4, r5, r6, lr}
000179fa 4c4177fa 82b0       sub sp, #8
000179fc 4c4177fc 274d       ldr r5, [pc, #0x9c]
000179fe 4c4177fe 0024       movs r4, #0
00017a00 4c417800 0646       mov r6, r0
00017a02 4c417802 6846       mov r0, sp
00017a04 4c417804 0094       str r4, [sp]
00017a06 4c417806 0194       str r4, [sp, #4]
00017a08 4c417808 7d44       add r5, pc
00017a0a 4c41780a 54f081ff   bl #0x4c46c710
00017a0e 4c41780e 00b1       cbz r0, #0x4c417812
00017a10 4c417810 0094       str r4, [sp]
00017a12 4c417812 01a8       add r0, sp, #4
00017a14 4c417814 0ef08ef9   bl #0x4c425b34
00017a18 4c417818 019b       ldr r3, [sp, #4]
00017a1a 4c41781a 5a1e       subs r2, r3, #1
00017a1c 4c41781c 012a       cmp r2, #1
00017a1e 4c41781e 30d9       bls #0x4c417882
00017a20 4c417820 033b       subs r3, #3
00017a22 4c417822 012b       cmp r3, #1
00017a24 4c417824 01d9       bls #0x4c41782a
00017a26 4c417826 0423       movs r3, #4
00017a28 4c417828 0193       str r3, [sp, #4]
00017a2a 4c41782a 1d48       ldr r0, [pc, #0x74]
00017a2c 4c41782c 0099       ldr r1, [sp]
00017a2e 4c41782e 7844       add r0, pc
00017a30 4c417830 27f034fe   bl #0x4c43f49c
00017a34 4c417834 1b48       ldr r0, [pc, #0x6c]
00017a36 4c417836 0199       ldr r1, [sp, #4]
00017a38 4c417838 7844       add r0, pc
00017a3a 4c41783a 27f02ffe   bl #0x4c43f49c
00017a3e 4c41783e 009b       ldr r3, [sp]
00017a40 4c417840 6bb9       cbnz r3, #0x4c41785e
00017a42 4c417842 019b       ldr r3, [sp, #4]
00017a44 4c417844 184a       ldr r2, [pc, #0x60]
00017a46 4c417846 032b       cmp r3, #3
00017a48 4c417848 4fea4613   lsl.w r3, r6, #5
00017a4c 4c41784c a3eb8606   sub.w r6, r3, r6, lsl #2
00017a50 4c417850 ab58       ldr r3, [r5, r2]
00017a52 4c417852 1e44       add r6, r3
00017a54 4c417854 0cbf       ite eq
00017a56 4c417856 707d       ldrbeq r0, [r6, #0x15]
00017a58 4c417858 307d       ldrbne r0, [r6, #0x14]
00017a5a 4c41785a 02b0       add sp, #8
00017a5c 4c41785c 70bd       pop {r4, r5, r6, pc}
00017a5e 4c41785e 012b       cmp r3, #1
00017a60 4c417860 18bf       it ne
00017a62 4c417862 0020       movne r0, #0
00017a64 4c417864 f9d1       bne #0x4c41785a
00017a66 4c417866 019b       ldr r3, [sp, #4]
00017a68 4c417868 0f4a       ldr r2, [pc, #0x3c]
00017a6a 4c41786a 032b       cmp r3, #3
00017a6c 4c41786c 4fea4613   lsl.w r3, r6, #5
00017a70 4c417870 a3eb8606   sub.w r6, r3, r6, lsl #2
00017a74 4c417874 ab58       ldr r3, [r5, r2]
00017a76 4c417876 1e44       add r6, r3
00017a78 4c417878 0cbf       ite eq
00017a7a 4c41787a f07d       ldrbeq r0, [r6, #0x17]
00017a7c 4c41787c b07d       ldrbne r0, [r6, #0x16]
00017a7e 4c41787e 02b0       add sp, #8
00017a80 4c417880 70bd       pop {r4, r5, r6, pc}
00017a82 4c417882 0a48       ldr r0, [pc, #0x28]
00017a84 4c417884 0423       movs r3, #4
00017a86 4c417886 0099       ldr r1, [sp]
00017a88 4c417888 0193       str r3, [sp, #4]
00017a8a 4c41788a 7844       add r0, pc
00017a8c 4c41788c 27f006fe   bl #0x4c43f49c
00017a90 4c417890 0748       ldr r0, [pc, #0x1c]
00017a92 4c417892 0199       ldr r1, [sp, #4]
00017a94 4c417894 7844       add r0, pc
00017a96 4c417896 27f001fe   bl #0x4c43f49c

; Region 0x17b2c
00017b2c 4c41792c 08b5       push {r3, lr}
00017b2e 4c41792e fff763ff   bl #0x4c4177f8
00017b32 4c417932 c0f34000   ubfx r0, r0, #1, #1
00017b36 4c417936 08bd       pop {r3, pc}

; Region 0x55bdc
00055bdc 4c4559dc 2de9f041   push.w {r4, r5, r6, r7, r8, lr}
00055be0 4c4559e0 0a46       mov r2, r1
00055be2 4c4559e2 0446       mov r4, r0
00055be4 4c4559e4 0d46       mov r5, r1
00055be6 4c4559e6 0146       mov r1, r0
00055be8 4c4559e8 82b0       sub sp, #8
00055bea 4c4559ea 3948       ldr r0, [pc, #0xe4]
00055bec 4c4559ec f046       mov r8, lr
00055bee 4c4559ee 394f       ldr r7, [pc, #0xe4]
00055bf0 4c4559f0 394e       ldr r6, [pc, #0xe4]
00055bf2 4c4559f2 7844       add r0, pc
00055bf4 4c4559f4 e9f752fd   bl #0x4c43f49c
00055bf8 4c4559f8 2046       mov r0, r4
00055bfa 4c4559fa 7f44       add r7, pc
00055bfc 4c4559fc c1f75aff   bl #0x4c4178b4
00055c00 4c455a00 0346       mov r3, r0
00055c02 4c455a02 3648       ldr r0, [pc, #0xd8]
00055c04 4c455a04 1946       mov r1, r3
00055c06 4c455a06 3b60       str r3, [r7]
00055c08 4c455a08 7e44       add r6, pc
00055c0a 4c455a0a 7844       add r0, pc
00055c0c 4c455a0c e9f746fd   bl #0x4c43f49c
00055c10 4c455a10 3868       ldr r0, [r7]
00055c12 4c455a12 c1f78bff   bl #0x4c41792c
00055c16 4c455a16 0346       mov r3, r0
00055c18 4c455a18 3148       ldr r0, [pc, #0xc4]
00055c1a 4c455a1a 1946       mov r1, r3
00055c1c 4c455a1c 3360       str r3, [r6]
00055c1e 4c455a1e 7844       add r0, pc
00055c20 4c455a20 e9f73cfd   bl #0x4c43f49c
00055c24 4c455a24 3368       ldr r3, [r6]
00055c26 4c455a26 6bb9       cbnz r3, #0x4c455a44
00055c28 4c455a28 2e4b       ldr r3, [pc, #0xb8]
00055c2a 4c455a2a 7b44       add r3, pc
00055c2c 4c455a2c 1b68       ldr r3, [r3]
00055c2e 4c455a2e 012b       cmp r3, #1
00055c30 4c455a30 08d0       beq #0x4c455a44
00055c32 4c455a32 2d4b       ldr r3, [pc, #0xb4]
00055c34 4c455a34 7b44       add r3, pc
00055c36 4c455a36 1b68       ldr r3, [r3]
00055c38 4c455a38 012b       cmp r3, #1
00055c3a 4c455a3a 03d0       beq #0x4c455a44
00055c3c 4c455a3c 0020       movs r0, #0
00055c3e 4c455a3e 02b0       add sp, #8
00055c40 4c455a40 bde8f081   pop.w {r4, r5, r6, r7, r8, pc}

; Region 0x55d18
00055d18 4c455b18 2de9f043   push.w {r4, r5, r6, r7, r8, sb, lr}
00055d1c 4c455b1c 0c46       mov r4, r1
00055d1e 4c455b1e 0146       mov r1, r0
00055d20 4c455b20 4348       ldr r0, [pc, #0x10c]
00055d22 4c455b22 83b0       sub sp, #0xc
00055d24 4c455b24 1546       mov r5, r2
00055d26 4c455b26 0093       str r3, [sp]
00055d28 4c455b28 1e46       mov r6, r3
00055d2a 4c455b2a 2246       mov r2, r4
00055d2c 4c455b2c 2b46       mov r3, r5
00055d2e 4c455b2e 7844       add r0, pc
00055d30 4c455b30 f146       mov sb, lr
00055d32 4c455b32 e9f7b3fc   bl #0x4c43f49c
00055d36 4c455b36 3f4b       ldr r3, [pc, #0xfc]
00055d38 4c455b38 7b44       add r3, pc
00055d3a 4c455b3a 1b68       ldr r3, [r3]
00055d3c 4c455b3c 4bb3       cbz r3, #0x4c455b92
00055d3e 4c455b3e 3e4f       ldr r7, [pc, #0xf8]
00055d40 4c455b40 0123       movs r3, #1
00055d42 4c455b42 3e49       ldr r1, [pc, #0xf8]
00055d44 4c455b44 2046       mov r0, r4
00055d46 4c455b46 0722       movs r2, #7
00055d48 4c455b48 7f44       add r7, pc
00055d4a 4c455b4a 7944       add r1, pc
00055d4c 4c455b4c 3b60       str r3, [r7]
00055d4e 4c455b4e eaf7cdfd   bl #0x4c4406ec
00055d52 4c455b52 8046       mov r8, r0
00055d54 4c455b54 00bb       cbnz r0, #0x4c455b98
00055d56 4c455b56 3a4b       ldr r3, [pc, #0xe8]
00055d58 4c455b58 7b44       add r3, pc
00055d5a 4c455b5a 1b68       ldr r3, [r3]
00055d5c 4c455b5c 012b       cmp r3, #1
00055d5e 4c455b5e 3fd0       beq #0x4c455be0
00055d60 4c455b60 3848       ldr r0, [pc, #0xe0]
00055d62 4c455b62 7844       add r0, pc
00055d64 4c455b64 e9f79afc   bl #0x4c43f49c
00055d68 4c455b68 3749       ldr r1, [pc, #0xdc]
00055d6a 4c455b6a 2046       mov r0, r4
00055d6c 4c455b6c 0722       movs r2, #7
00055d6e 4c455b6e 7944       add r1, pc
00055d70 4c455b70 eaf7bcfd   bl #0x4c4406ec
00055d74 4c455b74 40b9       cbnz r0, #0x4c455b88
00055d76 4c455b76 354b       ldr r3, [pc, #0xd4]
00055d78 4c455b78 7b44       add r3, pc
00055d7a 4c455b7a 1b68       ldr r3, [r3]
00055d7c 4c455b7c 012b       cmp r3, #1
00055d7e 4c455b7e 3ed0       beq #0x4c455bfe
00055d80 4c455b80 3348       ldr r0, [pc, #0xcc]
00055d82 4c455b82 7844       add r0, pc
00055d84 4c455b84 e9f78afc   bl #0x4c43f49c
00055d88 4c455b88 324b       ldr r3, [pc, #0xc8]
00055d8a 4c455b8a 7b44       add r3, pc
00055d8c 4c455b8c 1b68       ldr r3, [r3]
00055d8e 4c455b8e 012b       cmp r3, #1
00055d90 4c455b90 0ad0       beq #0x4c455ba8
00055d92 4c455b92 03b0       add sp, #0xc
00055d94 4c455b94 bde8f083   pop.w {r4, r5, r6, r7, r8, sb, pc}
00055d98 4c455b98 2f49       ldr r1, [pc, #0xbc]
00055d9a 4c455b9a 2046       mov r0, r4
00055d9c 4c455b9c 0722       movs r2, #7
00055d9e 4c455b9e 7944       add r1, pc
00055da0 4c455ba0 eaf7a4fd   bl #0x4c4406ec
00055da4 4c455ba4 0028       cmp r0, #0
00055da6 4c455ba6 e6d0       beq #0x4c455b76
00055da8 4c455ba8 2c4f       ldr r7, [pc, #0xb0]
00055daa 4c455baa 0020       movs r0, #0
00055dac 4c455bac 08f0f8f8   bl #0x4c45dda0
00055db0 4c455bb0 3146       mov r1, r6
00055db2 4c455bb2 7f44       add r7, pc
00055db4 4c455bb4 3860       str r0, [r7]
00055db6 4c455bb6 2846       mov r0, r5
00055db8 4c455bb8 17f006f8   bl #0x4c46cbc8
00055dbc 4c455bbc 0146       mov r1, r0
00055dbe 4c455bbe 38bb       cbnz r0, #0x4c455c10
00055dc0 4c455bc0 2748       ldr r0, [pc, #0x9c]
00055dc2 4c455bc2 7844       add r0, pc
00055dc4 4c455bc4 e9f76afc   bl #0x4c43f49c
00055dc8 4c455bc8 3868       ldr r0, [r7]
00055dca 4c455bca 08f0e9f8   bl #0x4c45dda0
00055dce 4c455bce 0246       mov r2, r0
00055dd0 4c455bd0 2448       ldr r0, [pc, #0x90]
00055dd2 4c455bd2 2146       mov r1, r4
00055dd4 4c455bd4 7844       add r0, pc
00055dd6 4c455bd6 03b0       add sp, #0xc
00055dd8 4c455bd8 bde8f043   pop.w {r4, r5, r6, r7, r8, sb, lr}
00055ddc 4c455bdc e9f75ebc   b.w #0x4c43f49c
00055de0 4c455be0 2148       ldr r0, [pc, #0x84]
00055de2 4c455be2 7844       add r0, pc
00055de4 4c455be4 e9f75afc   bl #0x4c43f49c
00055de8 4c455be8 2049       ldr r1, [pc, #0x80]
00055dea 4c455bea 2046       mov r0, r4
00055dec 4c455bec 0722       movs r2, #7
00055dee 4c455bee c7f80080   str.w r8, [r7]
00055df2 4c455bf2 7944       add r1, pc
00055df4 4c455bf4 eaf77afd   bl #0x4c4406ec
00055df8 4c455bf8 0028       cmp r0, #0
00055dfa 4c455bfa cad1       bne #0x4c455b92
00055dfc 4c455bfc bbe7       b #0x4c455b76
00055dfe 4c455bfe 1c48       ldr r0, [pc, #0x70]
00055e00 4c455c00 7844       add r0, pc
00055e02 4c455c02 e9f74bfc   bl #0x4c43f49c
00055e06 4c455c06 1b4b       ldr r3, [pc, #0x6c]
00055e08 4c455c08 0022       movs r2, #0
00055e0a 4c455c0a 7b44       add r3, pc
00055e0c 4c455c0c 1a60       str r2, [r3]
00055e0e 4c455c0e c0e7       b #0x4c455b92
00055e10 4c455c10 1948       ldr r0, [pc, #0x64]
00055e12 4c455c12 1a4c       ldr r4, [pc, #0x68]
00055e14 4c455c14 7844       add r0, pc
00055e16 4c455c16 e9f741fc   bl #0x4c43f49c
00055e1a 4c455c1a 1949       ldr r1, [pc, #0x64]
00055e1c 4c455c1c 7c44       add r4, pc
00055e1e 4c455c1e 194a       ldr r2, [pc, #0x64]
00055e20 4c455c20 4846       mov r0, sb
00055e22 4c455c22 c423       movs r3, #0xc4
00055e24 4c455c24 0094       str r4, [sp]
00055e26 4c455c26 7944       add r1, pc
00055e28 4c455c28 7a44       add r2, pc
00055e2a 4c455c2a e9f7e1fc   bl #0x4c43f5f0
