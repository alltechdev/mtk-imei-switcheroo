; Supplied preloader. File offset, runtime address, bytes, Thumb instruction.
; Names inferred from control flow and supplied MT6768 source.

; get_sec_policy
0002f6ac  0022fdbc  37b5       push {r0, r1, r2, r4, r5, lr}
0002f6ae  0022fdbe  0446       mov r4, r0
0002f6b0  0022fdc0  6846       mov r0, sp
0002f6b2  0022fdc2  0023       movs r3, #0
0002f6b4  0022fdc4  0093       str r3, [sp]
0002f6b6  0022fdc6  0193       str r3, [sp, #4]
0002f6b8  0022fdc8  05f0dafd   bl #0x235980
0002f6bc  0022fdcc  08b1       cbz r0, #0x22fdd2
0002f6be  0022fdce  0123       movs r3, #1
0002f6c0  0022fdd0  0093       str r3, [sp]
0002f6c2  0022fdd2  01a8       add r0, sp, #4
0002f6c4  0022fdd4  05f0e0fd   bl #0x235998
0002f6c8  0022fdd8  08b1       cbz r0, #0x22fdde
0002f6ca  0022fdda  0123       movs r3, #1
0002f6cc  0022fddc  0193       str r3, [sp, #4]
0002f6ce  0022fdde  019b       ldr r3, [sp, #4]
0002f6d0  0022fde0  5a1e       subs r2, r3, #1
0002f6d2  0022fde2  012a       cmp r2, #1
0002f6d4  0022fde4  02d8       bhi #0x22fdec
0002f6d6  0022fde6  0425       movs r5, #4
0002f6d8  0022fde8  0195       str r5, [sp, #4]
0002f6da  0022fdea  05e0       b #0x22fdf8
0002f6dc  0022fdec  033b       subs r3, #3
0002f6de  0022fdee  0025       movs r5, #0
0002f6e0  0022fdf0  012b       cmp r3, #1
0002f6e2  0022fdf2  84bf       itt hi
0002f6e4  0022fdf4  0423       movhi r3, #4
0002f6e6  0022fdf6  0193       strhi r3, [sp, #4]
0002f6e8  0022fdf8  1748       ldr r0, [pc, #0x5c]
0002f6ea  0022fdfa  0099       ldr r1, [sp]
0002f6ec  0022fdfc  7844       add r0, pc
0002f6ee  0022fdfe  fdf7b1fd   bl #0x22d964
0002f6f2  0022fe02  15b9       cbnz r5, #0x22fe0a
0002f6f4  0022fe04  1548       ldr r0, [pc, #0x54]
0002f6f6  0022fe06  7844       add r0, pc
0002f6f8  0022fe08  01e0       b #0x22fe0e
0002f6fa  0022fe0a  1548       ldr r0, [pc, #0x54]
0002f6fc  0022fe0c  7844       add r0, pc
0002f6fe  0022fe0e  0199       ldr r1, [sp, #4]
0002f700  0022fe10  fdf7a8fd   bl #0x22d964
0002f704  0022fe14  009b       ldr r3, [sp]
0002f706  0022fe16  63b9       cbnz r3, #0x22fe32
0002f708  0022fe18  019b       ldr r3, [sp, #4]
0002f70a  0022fe1a  124a       ldr r2, [pc, #0x48]
0002f70c  0022fe1c  032b       cmp r3, #3
0002f70e  0022fe1e  4ff01c03   mov.w r3, #0x1c
0002f712  0022fe22  7a44       add r2, pc
0002f714  0022fe24  1268       ldr r2, [r2]
0002f716  0022fe26  03fb0423   mla r3, r3, r4, r2
0002f71a  0022fe2a  0cbf       ite eq
0002f71c  0022fe2c  587d       ldrbeq r0, [r3, #0x15]
0002f71e  0022fe2e  187d       ldrbne r0, [r3, #0x14]
0002f720  0022fe30  10e0       b #0x22fe54
0002f722  0022fe32  012b       cmp r3, #1
0002f724  0022fe34  0dd1       bne #0x22fe52
0002f726  0022fe36  019b       ldr r3, [sp, #4]
0002f728  0022fe38  1c22       movs r2, #0x1c
0002f72a  0022fe3a  032b       cmp r3, #3
0002f72c  0022fe3c  0a4b       ldr r3, [pc, #0x28]
0002f72e  0022fe3e  7b44       add r3, pc
0002f730  0022fe40  1b68       ldr r3, [r3]
0002f732  0022fe42  0bbf       itete eq
0002f734  0022fe44  02fb0433   mlaeq r3, r2, r4, r3
0002f738  0022fe48  02fb0434   mlane r4, r2, r4, r3
0002f73c  0022fe4c  d87d       ldrbeq r0, [r3, #0x17]
0002f73e  0022fe4e  a07d       ldrbne r0, [r4, #0x16]
0002f740  0022fe50  00e0       b #0x22fe54
0002f742  0022fe52  0020       movs r0, #0
0002f744  0022fe54  03b0       add sp, #0xc
0002f746  0022fe56  30bd       pop {r4, r5, pc}

; get_vfy_policy
0002f7d4  0022fee4  08b5       push {r3, lr}
0002f7d6  0022fee6  fff769ff   bl #0x22fdbc
0002f7da  0022feea  c0f34000   ubfx r0, r0, #1, #1
0002f7de  0022feee  08bd       pop {r3, pc}

; part_load policy acquisition
00029570  00229c80  06f0f4f8   bl #0x22fe6c
00029574  00229c84  dff88892   ldr.w sb, [pc, #0x288]
00029578  00229c88  06f02cf9   bl #0x22fee4
0002957c  00229c8c  f944       add sb, pc
0002957e  00229c8e  4946       mov r1, sb
00029580  00229c90  0590       str r0, [sp, #0x14]
00029582  00229c92  a048       ldr r0, [pc, #0x280]
00029584  00229c94  059a       ldr r2, [sp, #0x14]
00029586  00229c96  7844       add r0, pc
00029588  00229c98  03f064fe   bl #0x22d964

; part_load certificate and rollback checks
000295ca  00229cda  06f0abfd   bl #0x230834
000295ce  00229cde  059b       ldr r3, [sp, #0x14]
000295d0  00229ce0  8346       mov fp, r0
000295d2  00229ce2  2bb3       cbz r3, #0x229d30
000295d4  00229ce4  05f044fe   bl #0x22f970
000295d8  00229ce8  0b9b       ldr r3, [sp, #0x2c]
000295da  00229cea  2846       mov r0, r5
000295dc  00229cec  03f59561   add.w r1, r3, #0x4a8
000295e0  00229cf0  0cf052f9   bl #0x235f98
000295e4  00229cf4  58b1       cbz r0, #0x229d0e
000295e6  00229cf6  8948       ldr r0, [pc, #0x224]
000295e8  00229cf8  4946       mov r1, sb
000295ea  00229cfa  7844       add r0, pc
000295ec  00229cfc  03f032fe   bl #0x22d964
000295f0  00229d00  8748       ldr r0, [pc, #0x21c]
000295f2  00229d02  884a       ldr r2, [pc, #0x220]
000295f4  00229d04  9f21       movs r1, #0x9f
000295f6  00229d06  7844       add r0, pc
000295f8  00229d08  7a44       add r2, pc
000295fa  00229d0a  01f04ff9   bl #0x22afac
000295fe  00229d0e  0020       movs r0, #0
00029600  00229d10  0df0f8fb   bl #0x237504
00029604  00229d14  60b1       cbz r0, #0x229d30
00029606  00229d16  8448       ldr r0, [pc, #0x210]
00029608  00229d18  8449       ldr r1, [pc, #0x210]
0002960a  00229d1a  7844       add r0, pc
0002960c  00229d1c  7944       add r1, pc
0002960e  00229d1e  03f021fe   bl #0x22d964
00029612  00229d22  8348       ldr r0, [pc, #0x20c]
00029614  00229d24  834a       ldr r2, [pc, #0x20c]
00029616  00229d26  a521       movs r1, #0xa5
00029618  00229d28  7844       add r0, pc
0002961a  00229d2a  7a44       add r2, pc
0002961c  00229d2c  01f03ef9   bl #0x22afac

; part_load image authentication
00029778  00229e88  0020       movs r0, #0
0002977a  00229e8a  06f0d3fc   bl #0x230834
0002977e  00229e8e  059b       ldr r3, [sp, #0x14]
00029780  00229e90  0646       mov r6, r0
00029782  00229e92  8bb1       cbz r3, #0x229eb8
00029784  00229e94  0e98       ldr r0, [sp, #0x38]
00029786  00229e96  0d99       ldr r1, [sp, #0x34]
00029788  00229e98  0cf0dcf9   bl #0x236254
0002978c  00229e9c  0446       mov r4, r0
0002978e  00229e9e  58b1       cbz r0, #0x229eb8
00029790  00229ea0  3148       ldr r0, [pc, #0xc4]
00029792  00229ea2  2146       mov r1, r4
00029794  00229ea4  7844       add r0, pc
00029796  00229ea6  03f05dfd   bl #0x22d964
0002979a  00229eaa  3048       ldr r0, [pc, #0xc0]
0002979c  00229eac  304a       ldr r2, [pc, #0xc0]
0002979e  00229eae  d021       movs r1, #0xd0
000297a0  00229eb0  7844       add r0, pc
000297a2  00229eb2  7a44       add r2, pc
000297a4  00229eb4  01f07af8   bl #0x22afac

; get_lock_state
00035288  00235998  074b       ldr r3, [pc, #0x1c]
0003528a  0023599a  7b44       add r3, pc
0003528c  0023599c  1b68       ldr r3, [r3]
0003528e  0023599e  1b68       ldr r3, [r3]
00035290  002359a0  2bb1       cbz r3, #0x2359ae
00035292  002359a2  064b       ldr r3, [pc, #0x18]
00035294  002359a4  7b44       add r3, pc
00035296  002359a6  1b68       ldr r3, [r3]
00035298  002359a8  1b68       ldr r3, [r3]
0003529a  002359aa  db68       ldr r3, [r3, #0xc]
0003529c  002359ac  00e0       b #0x2359b0
0003529e  002359ae  0123       movs r3, #1
000352a0  002359b0  0360       str r3, [r0]
000352a2  002359b2  0020       movs r0, #0
000352a4  002359b4  7047       bx lr
