; ROM offset | runtime VA | bytes | decoded instruction
; Decoder: analysis/mips16_subset.py (limited MIPS16 decoder; no unresolved encodings here)
012eba08  912eba08  f4 64        save 32, ra, s0, s1
012eba0a  912eba0a  02 f0 00 6c  li a0, 0x1000
012eba0e  912eba0e  42 b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012eba10  912eba10  41 f0 0b 6e  li a2, 0x84b
012eba14  912eba14  a1 18 95 21  jal 0x90948654
012eba18  912eba18  00 65        nop
012eba1a  912eba1a  02 67        move s0, v0
012eba1c  912eba1c  04 2a        bnez v0, 0x912eba26
012eba1e  912eba1e  3e b4        lw a0, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012eba20  912eba20  41 f0 0d 6d  li a1, 0x84d
012eba24  912eba24  05 ea        break 16
012eba26  912eba26  3d b5        lw a1, [0x912ebb18] ; =0x914f85b0 'lcsh custom_nvram_read_and_check_signed_critical_data'
012eba28  912eba28  40 19 ec 5a  jal 0x90296bb0
012eba2c  912eba2c  02 6c        li a0, 0x2
012eba2e  912eba2e  62 19 20 ae  jal 0x912eb880
012eba32  912eba32  00 65        nop
012eba34  912eba34  09 2a        bnez v0, 0x912eba48
012eba36  912eba36  38 b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012eba38  912eba38  41 f0 13 6e  li a2, 0x853
012eba3c  912eba3c  a1 18 98 21  jal 0x90948660
012eba40  912eba40  90 67        move a0, s0
012eba42  912eba42  02 6c        li a0, 0x2
012eba44  912eba44  36 b5        lw a1, [0x912ebb1c] ; =0x914f85e8 'lcsh skip IMEI check'
012eba46  912eba46  26 10        b 0x912eba94
012eba48  912eba48  1d f7 10 6c  li a0, 0xef10
012eba4c  912eba4c  01 6d        li a1, 0x1
012eba4e  912eba4e  d0 67        move a2, s0
012eba50  912eba50  c1 19 f1 ca  jal 0x90bb2bc4
012eba54  912eba54  0a 6f        li a3, 0xa
012eba56  912eba56  01 72        cmpi v0, 0x1
012eba58  912eba58  09 60        bteqz 0x912eba6c
012eba5a  912eba5a  2f b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012eba5c  912eba5c  41 f0 1b 6e  li a2, 0x85b
012eba60  912eba60  a1 18 98 21  jal 0x90948660
012eba64  912eba64  90 67        move a0, s0
012eba66  912eba66  02 6c        li a0, 0x2
012eba68  912eba68  2e b5        lw a1, [0x912ebb20] ; =0x914f8600 'custom_nvram_read_and_check_signed_critical_data read imei fail'
012eba6a  912eba6a  3f 10        b 0x912ebaea
012eba6c  912eba6c  30 67        move s1, s0
012eba6e  912eba6e  00 f0 8a 40  addiu a0, s0, 10
012eba72  912eba72  70 67        move v1, s0
012eba74  912eba74  ff 6a        li v0, 0xff
012eba76  912eba76  a0 a3        lbu a1, 0(v1)
012eba78  912eba78  01 4b        addiu v1, 1
012eba7a  912eba7a  8a eb        cmp v1, a0
012eba7c  912eba7c  ac ea        and v0, a1
012eba7e  912eba7e  fb 61        btnez 0x912eba76
012eba80  912eba80  ff 72        cmpi v0, 0xff
012eba82  912eba82  0c 61        btnez 0x912eba9c
012eba84  912eba84  24 b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012eba86  912eba86  61 f0 07 6e  li a2, 0x867
012eba8a  912eba8a  a1 18 98 21  jal 0x90948660
012eba8e  912eba8e  90 67        move a0, s0
012eba90  912eba90  02 6c        li a0, 0x2
012eba92  912eba92  25 b5        lw a1, [0x912ebb24] ; =0x914f8640 'custom_nvram_read_and_check_signed_critical_data imei is default value, bypass check'
012eba94  912eba94  40 19 ec 5a  jal 0x90296bb0
012eba98  912eba98  01 69        li s1, 0x1
012eba9a  912eba9a  38 10        b 0x912ebb0c
012eba9c  912eba9c  c1 f0 01 6c  li a0, 0x8c1
012ebaa0  912ebaa0  01 6d        li a1, 0x1
012ebaa2  912ebaa2  02 f0 00 6f  li a3, 0x1000
012ebaa6  912ebaa6  c1 19 f1 ca  jal 0x90bb2bc4
012ebaaa  912ebaaa  d0 67        move a2, s0
012ebaac  912ebaac  01 72        cmpi v0, 0x1
012ebaae  912ebaae  04 61        btnez 0x912ebab8
012ebab0  912ebab0  02 f0 60 40  addiu v1, s0, 4096
012ebab4  912ebab4  00 6a        li v0, 0x0
012ebab6  912ebab6  09 10        b 0x912ebaca
012ebab8  912ebab8  17 b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012ebaba  912ebaba  61 f0 0f 6e  li a2, 0x86f
012ebabe  912ebabe  a1 18 98 21  jal 0x90948660
012ebac2  912ebac2  90 67        move a0, s0
012ebac4  912ebac4  02 6c        li a0, 0x2
012ebac6  912ebac6  19 b5        lw a1, [0x912ebb28] ; =0x914f8698 'custom_nvram_read_and_check_signed_critical_data read critical data fail'
012ebac8  912ebac8  10 10        b 0x912ebaea
012ebaca  912ebaca  6a e9        cmp s1, v1
012ebacc  912ebacc  04 60        bteqz 0x912ebad6
012ebace  912ebace  80 a1        lbu a0, 0(s1)
012ebad0  912ebad0  01 49        addiu s1, 1
012ebad2  912ebad2  8d ea        or v0, a0
012ebad4  912ebad4  fa 17        b 0x912ebaca
012ebad6  912ebad6  90 67        move a0, s0
012ebad8  912ebad8  0c 2a        bnez v0, 0x912ebaf2
012ebada  912ebada  0f b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012ebadc  912ebadc  61 f0 1b 6e  li a2, 0x87b
012ebae0  912ebae0  a1 18 98 21  jal 0x90948660
012ebae4  912ebae4  00 65        nop
012ebae6  912ebae6  02 6c        li a0, 0x2
012ebae8  912ebae8  11 b5        lw a1, [0x912ebb2c] ; =0x914f86e4 'custom_nvram_read_and_check_signed_critical_data sign data is default value, check fail'
012ebaea  912ebaea  40 19 ec 5a  jal 0x90296bb0
012ebaee  912ebaee  00 69        li s1, 0x0
012ebaf0  912ebaf0  0d 10        b 0x912ebb0c
012ebaf2  912ebaf2  02 f0 00 6d  li a1, 0x1000
012ebaf6  912ebaf6  62 19 ce ac  jal 0x912eb338
012ebafa  912ebafa  01 6e        li a2, 0x1
012ebafc  912ebafc  01 5a        sltiu v0, 1
012ebafe  912ebafe  90 67        move a0, s0
012ebb00  912ebb00  05 b5        lw a1, [0x912ebb14] ; =0x914f7f04 'pcore/custom/service/nvram/custom_nvram_sec.c'
012ebb02  912ebb02  81 f0 06 6e  li a2, 0x886
012ebb06  912ebb06  a1 18 98 21  jal 0x90948660
012ebb0a  912ebb0a  38 67        move s1, t8
012ebb0c  912ebb0c  51 67        move v0, s1
012ebb0e  912ebb0e  74 64        restore 32, ra, s0, s1
012ebb10  912ebb10  a0 e8        jrc ra
