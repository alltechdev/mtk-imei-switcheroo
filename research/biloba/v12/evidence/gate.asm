; ROM offset | runtime VA | bytes | decoded instruction
; Decoder: analysis/mips16_subset.py (limited MIPS16 decoder; no unresolved encodings here)
012eb880  912eb880  cf 64        save 120, ra
012eb882  912eb882  20 6e        li a2, 0x20
012eb884  912eb884  0c 04        addiu a0, sp, 48
012eb886  912eb886  a1 18 57 20  jal 0x9094815c
012eb88a  912eb88a  00 6d        li a1, 0x0
012eb88c  912eb88c  7d 67        move v1, sp
012eb88e  912eb88e  00 6a        li v0, 0x0
012eb890  912eb890  4b ea        neg v0, v0
012eb892  912eb892  02 6c        li a0, 0x2
012eb894  912eb894  49 b5        lw a1, [0x912eb9b8] ; =0x914f83c8 'lcsh is_enable_critical_data_check'
012eb896  912eb896  40 19 ec 5a  jal 0x90296bb0
012eb89a  912eb89a  5c c3        sb v0, 28(v1)
012eb89c  912eb89c  62 19 97 ac  jal 0x912eb25c
012eb8a0  912eb8a0  0c 04        addiu a0, sp, 48
012eb8a2  912eb8a2  01 52        slti v0, 1
012eb8a4  912eb8a4  80 f0 05 61  btnez 0x912eb9b2
012eb8a8  912eb8a8  02 6c        li a0, 0x2
012eb8aa  912eb8aa  45 b5        lw a1, [0x912eb9bc] ; =0x914f83ec 'lcsh get product name:%s'
012eb8ac  912eb8ac  40 19 ec 5a  jal 0x90296bb0
012eb8b0  912eb8b0  0c 06        addiu a2, sp, 48
012eb8b2  912eb8b2  0c 04        addiu a0, sp, 48
012eb8b4  912eb8b4  43 b5        lw a1, [0x912eb9c0] ; =0x914f8408 'secret'
012eb8b6  912eb8b6  82 1d 84 05  jalx 0x91301610
012eb8ba  912eb8ba  06 6e        li a2, 0x6
012eb8bc  912eb8bc  18 22        beqz v0, 0x912eb8ee
012eb8be  912eb8be  0c 04        addiu a0, sp, 48
012eb8c0  912eb8c0  41 b5        lw a1, [0x912eb9c4] ; =0x914f8410 'rosemary'
012eb8c2  912eb8c2  82 1d 84 05  jalx 0x91301610
012eb8c6  912eb8c6  08 6e        li a2, 0x8
012eb8c8  912eb8c8  12 22        beqz v0, 0x912eb8ee
012eb8ca  912eb8ca  0c 04        addiu a0, sp, 48
012eb8cc  912eb8cc  3f b5        lw a1, [0x912eb9c8] ; =0x914f841c 'maltose'
012eb8ce  912eb8ce  82 1d 84 05  jalx 0x91301610
012eb8d2  912eb8d2  07 6e        li a2, 0x7
012eb8d4  912eb8d4  0c 22        beqz v0, 0x912eb8ee
012eb8d6  912eb8d6  0c 04        addiu a0, sp, 48
012eb8d8  912eb8d8  3d b5        lw a1, [0x912eb9cc] ; =0x914f8424 'pending'
012eb8da  912eb8da  82 1d 84 05  jalx 0x91301610
012eb8de  912eb8de  07 6e        li a2, 0x7
012eb8e0  912eb8e0  06 22        beqz v0, 0x912eb8ee
012eb8e2  912eb8e2  0c 04        addiu a0, sp, 48
012eb8e4  912eb8e4  3b b5        lw a1, [0x912eb9d0] ; =0x914f842c 'biloba'
012eb8e6  912eb8e6  82 1d 84 05  jalx 0x91301610
012eb8ea  912eb8ea  06 6e        li a2, 0x6
012eb8ec  912eb8ec  62 2a        bnez v0, 0x912eb9b2
012eb8ee  912eb8ee  08 04        addiu a0, sp, 32
012eb8f0  912eb8f0  39 b5        lw a1, [0x912eb9d4] ; =0x914f85a0 'ro.boot.hwlevel'
012eb8f2  912eb8f2  69 1e 00 80  jalx 0x94ce0000
012eb8f6  912eb8f6  10 6e        li a2, 0x10
012eb8f8  912eb8f8  14 04        addiu a0, sp, 80
012eb8fa  912eb8fa  00 6d        li a1, 0x0
012eb8fc  912eb8fc  a1 18 57 20  jal 0x9094815c
012eb900  912eb900  20 6e        li a2, 0x20
012eb902  912eb902  20 6a        li v0, 0x20
012eb904  912eb904  04 d2        sw v0, 16(sp)
012eb906  912eb906  08 f0 0f 6c  li a0, 0x400f
012eb90a  912eb90a  08 05        addiu a1, sp, 32
012eb90c  912eb90c  10 6e        li a2, 0x10
012eb90e  912eb90e  a0 18 e1 9e  jal 0x90167b84
012eb912  912eb912  14 07        addiu a3, sp, 80
012eb914  912eb914  01 52        slti v0, 1
012eb916  912eb916  07 60        bteqz 0x912eb926
012eb918  912eb918  02 6c        li a0, 0x2
012eb91a  912eb91a  30 b5        lw a1, [0x912eb9d8] ; =0x914f8434 'lcsh custom_nvram_get_property_value :%s, got error:%d'
012eb91c  912eb91c  08 06        addiu a2, sp, 32
012eb91e  912eb91e  40 19 ec 5a  jal 0x90296bb0
012eb922  912eb922  e2 67        move a3, v0
012eb924  912eb924  46 10        b 0x912eb9b2
012eb926  912eb926  1c 03        addiu v1, sp, 112
012eb928  912eb928  49 e3        addu v0, v1, v0
012eb92a  912eb92a  00 6b        li v1, 0x0
012eb92c  912eb92c  6b eb        neg v1, v1
012eb92e  912eb92e  02 6c        li a0, 0x2
012eb930  912eb930  2b b5        lw a1, [0x912eb9dc] ; =0x914f846c 'lcsh get hwlevel:%s'
012eb932  912eb932  ff f7 60 c2  sb v1, -32(v0)
012eb936  912eb936  40 19 ec 5a  jal 0x90296bb0
012eb93a  912eb93a  14 06        addiu a2, sp, 80
012eb93c  912eb93c  29 b5        lw a1, [0x912eb9e0] ; =0x9141a9a0 '0'
012eb93e  912eb93e  82 1d 7f 04  jalx 0x913011fc
012eb942  912eb942  14 04        addiu a0, sp, 80
012eb944  912eb944  03 2a        bnez v0, 0x912eb94c
012eb946  912eb946  02 6c        li a0, 0x2
012eb948  912eb948  27 b5        lw a1, [0x912eb9e4] ; =0x914f8480 'lcsh is_enable_critical_data_check SKIP  P0'
012eb94a  912eb94a  30 10        b 0x912eb9ac
012eb94c  912eb94c  27 b5        lw a1, [0x912eb9e8] ; =0x9138bb38 '1'
012eb94e  912eb94e  82 1d 7f 04  jalx 0x913011fc
012eb952  912eb952  14 04        addiu a0, sp, 80
012eb954  912eb954  0a 22        beqz v0, 0x912eb96a
012eb956  912eb956  26 b5        lw a1, [0x912eb9ec] ; =0x914f84ac '1.1'
012eb958  912eb958  82 1d 7f 04  jalx 0x913011fc
012eb95c  912eb95c  14 04        addiu a0, sp, 80
012eb95e  912eb95e  05 22        beqz v0, 0x912eb96a
012eb960  912eb960  24 b5        lw a1, [0x912eb9f0] ; =0x914348f8 '2'
012eb962  912eb962  82 1d 7f 04  jalx 0x913011fc
012eb966  912eb966  14 04        addiu a0, sp, 80
012eb968  912eb968  14 2a        bnez v0, 0x912eb992
012eb96a  912eb96a  23 b5        lw a1, [0x912eb9f4] ; =0x914f84b0 'lcsh is_enable_critical_data_check P1 P1.1 P2+custom nv check'
012eb96c  912eb96c  40 19 ec 5a  jal 0x90296bb0
012eb970  912eb970  02 6c        li a0, 0x2
012eb972  912eb972  c1 f0 02 6c  li a0, 0x8c2
012eb976  912eb976  01 6d        li a1, 0x1
012eb978  912eb978  07 06        addiu a2, sp, 28
012eb97a  912eb97a  c1 19 f1 ca  jal 0x90bb2bc4
012eb97e  912eb97e  01 6f        li a3, 0x1
012eb980  912eb980  01 72        cmpi v0, 0x1
012eb982  912eb982  01 6a        li v0, 0x1
012eb984  912eb984  17 61        btnez 0x912eb9b4
012eb986  912eb986  7d 67        move v1, sp
012eb988  912eb988  7c a3        lbu v1, 28(v1)
012eb98a  912eb98a  14 23        beqz v1, 0x912eb9b4
012eb98c  912eb98c  02 6c        li a0, 0x2
012eb98e  912eb98e  1b b5        lw a1, [0x912eb9f8] ; =0x914f84f0 'lcsh is_enable_critical_data_check sign control data is not default value, skip'
012eb990  912eb990  0d 10        b 0x912eb9ac
012eb992  912eb992  1b b5        lw a1, [0x912eb9fc] ; =0x91368c9c 'MP'
012eb994  912eb994  82 1d 7f 04  jalx 0x913011fc
012eb998  912eb998  14 04        addiu a0, sp, 80
012eb99a  912eb99a  02 6c        li a0, 0x2
012eb99c  912eb99c  06 2a        bnez v0, 0x912eb9aa
012eb99e  912eb99e  19 b5        lw a1, [0x912eba00] ; =0x914f8540 'lcsh is_enable_critical_data_check MP'
012eb9a0  912eb9a0  40 19 ec 5a  jal 0x90296bb0
012eb9a4  912eb9a4  00 65        nop
012eb9a6  912eb9a6  01 6a        li v0, 0x1
012eb9a8  912eb9a8  05 10        b 0x912eb9b4
012eb9aa  912eb9aa  17 b5        lw a1, [0x912eba04] ; =0x914f8568 'lcsh is_enable_critical_data_check other hwlevel skip'
012eb9ac  912eb9ac  40 19 ec 5a  jal 0x90296bb0
012eb9b0  912eb9b0  00 65        nop
012eb9b2  912eb9b2  00 6a        li v0, 0x0
012eb9b4  912eb9b4  4f 64        restore 120, ra
012eb9b6  912eb9b6  a0 e8        jrc ra
