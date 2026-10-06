01316524  91316524  f5 64        save 40, ra, s0, s1
01316526  91316526  02 f0 00 6c  li a0, 0x1000
0131652a  9131652a  47 b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
0131652c  9131652c  81 f0 0d 6e  li a2, 0x88d
01316530  91316530  a1 18 95 4a  jal 0x90952a54
01316534  91316534  00 65        nop
01316536  91316536  02 67        move s0, v0
01316538  91316538  04 2a        bnez v0, 0x91316542
0131653a  9131653a  43 b4        lw a0, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
0131653c  9131653c  81 f0 0f 6d  li a1, 0x88f
01316540  91316540  05 ea        break 16
01316542  91316542  42 b5        lw a1, [0x91316648] ; =0x9152f634 'lcsh custom_nvram_read_and_check_signed_critical_data'
01316544  91316544  40 19 38 66  jal 0x902998e0
01316548  91316548  02 6c        li a0, 0x2
0131654a  9131654a  82 19 c8 58  jal 0x91316320
0131654e  9131654e  00 65        nop
01316550  91316550  09 2a        bnez v0, 0x91316564
01316552  91316552  3d b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
01316554  91316554  81 f0 15 6e  li a2, 0x895
01316558  91316558  a1 18 98 4a  jal 0x90952a60
0131655c  9131655c  90 67        move a0, s0
0131655e  9131655e  02 6c        li a0, 0x2
01316560  91316560  3b b5        lw a1, [0x9131664c] ; =0x9152f66c 'lcsh skip IMEI check'
01316562  91316562  2c 10        b 0x913165bc
01316564  91316564  1d f7 10 6c  li a0, 0xef10
01316568  91316568  01 6d        li a1, 0x1
0131656a  9131656a  d0 67        move a2, s0
0131656c  9131656c  e1 19 15 22  jal 0x90bc8854
01316570  91316570  0a 6f        li a3, 0xa
01316572  91316572  01 72        cmpi v0, 0x1
01316574  91316574  09 60        bteqz 0x91316588
01316576  91316576  34 b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
01316578  91316578  81 f0 1e 6e  li a2, 0x89e
0131657c  9131657c  a1 18 98 4a  jal 0x90952a60
01316580  91316580  90 67        move a0, s0
01316582  91316582  02 6c        li a0, 0x2
01316584  91316584  33 b5        lw a1, [0x91316650] ; =0x9152f684 'custom_nvram_read_and_check_signed_critical_data read imei fail'
01316586  91316586  49 10        b 0x9131661a
01316588  91316588  30 67        move s1, s0
0131658a  9131658a  00 f0 8a 40  addiu a0, s0, 10
0131658e  9131658e  50 67        move v0, s0
01316590  91316590  ff 6b        li v1, 0xff
01316592  91316592  a0 a2        lbu a1, 0(v0)
01316594  91316594  01 4a        addiu v0, 1
01316596  91316596  8a ea        cmp v0, a0
01316598  91316598  ac eb        and v1, a1
0131659a  9131659a  fb 61        btnez 0x91316592
0131659c  9131659c  82 19 36 59  jal 0x913164d8
013165a0  913165a0  05 d3        sw v1, 20(sp)
013165a2  913165a2  01 72        cmpi v0, 0x1
013165a4  913165a4  13 60        bteqz 0x913165cc
013165a6  913165a6  05 93        lw v1, 20(sp)
013165a8  913165a8  ff 73        cmpi v1, 0xff
013165aa  913165aa  0c 61        btnez 0x913165c4
013165ac  913165ac  26 b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
013165ae  913165ae  a1 f0 0d 6e  li a2, 0x8ad
013165b2  913165b2  a1 18 98 4a  jal 0x90952a60
013165b6  913165b6  90 67        move a0, s0
013165b8  913165b8  02 6c        li a0, 0x2
013165ba  913165ba  27 b5        lw a1, [0x91316654] ; =0x9152f6c4 'custom_nvram_read_and_check_signed_critical_data imei is default value, bypass check'
013165bc  913165bc  40 19 38 66  jal 0x902998e0
013165c0  913165c0  01 69        li s1, 0x1
013165c2  913165c2  3c 10        b 0x9131663c
013165c4  913165c4  25 b5        lw a1, [0x91316658] ; =0x9152f71c 'custom_nvram_read_and_check_signed_critical_data is factory or old boardid'
013165c6  913165c6  40 19 38 66  jal 0x902998e0
013165ca  913165ca  02 6c        li a0, 0x2
013165cc  913165cc  c1 f0 01 6c  li a0, 0x8c1
013165d0  913165d0  01 6d        li a1, 0x1
013165d2  913165d2  02 f0 00 6f  li a3, 0x1000
013165d6  913165d6  e1 19 15 22  jal 0x90bc8854
013165da  913165da  d0 67        move a2, s0
013165dc  913165dc  01 72        cmpi v0, 0x1
013165de  913165de  04 61        btnez 0x913165e8
013165e0  913165e0  02 f0 60 40  addiu v1, s0, 4096
013165e4  913165e4  00 6a        li v0, 0x0
013165e6  913165e6  09 10        b 0x913165fa
013165e8  913165e8  17 b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
013165ea  913165ea  a1 f0 17 6e  li a2, 0x8b7
013165ee  913165ee  a1 18 98 4a  jal 0x90952a60
013165f2  913165f2  90 67        move a0, s0
013165f4  913165f4  02 6c        li a0, 0x2
013165f6  913165f6  1a b5        lw a1, [0x9131665c] ; =0x9152f768 'custom_nvram_read_and_check_signed_critical_data read critical data fail'
013165f8  913165f8  10 10        b 0x9131661a
013165fa  913165fa  6a e9        cmp s1, v1
013165fc  913165fc  04 60        bteqz 0x91316606
013165fe  913165fe  80 a1        lbu a0, 0(s1)
01316600  91316600  01 49        addiu s1, 1
01316602  91316602  8d ea        or v0, a0
01316604  91316604  fa 17        b 0x913165fa
01316606  91316606  90 67        move a0, s0
01316608  91316608  0c 2a        bnez v0, 0x91316622
0131660a  9131660a  0f b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
0131660c  9131660c  c1 f0 03 6e  li a2, 0x8c3
01316610  91316610  a1 18 98 4a  jal 0x90952a60
01316614  91316614  00 65        nop
01316616  91316616  02 6c        li a0, 0x2
01316618  91316618  12 b5        lw a1, [0x91316660] ; =0x9152f7b4 'custom_nvram_read_and_check_signed_critical_data sign data is default value, check fail'
0131661a  9131661a  40 19 38 66  jal 0x902998e0
0131661e  9131661e  00 69        li s1, 0x0
01316620  91316620  0d 10        b 0x9131663c
01316622  91316622  02 f0 00 6d  li a1, 0x1000
01316626  91316626  82 19 76 57  jal 0x91315dd8
0131662a  9131662a  01 6e        li a2, 0x1
0131662c  9131662c  01 5a        sltiu v0, 1
0131662e  9131662e  90 67        move a0, s0
01316630  91316630  05 b5        lw a1, [0x91316644] ; =0x9152ee80 'pcore/custom/service/nvram/custom_nvram_sec.c'
01316632  91316632  c1 f0 0e 6e  li a2, 0x8ce
01316636  91316636  a1 18 98 4a  jal 0x90952a60
0131663a  9131663a  38 67        move s1, t8
0131663c  9131663c  51 67        move v0, s1
0131663e  9131663e  75 64        restore 40, ra, s0, s1
01316640  91316640  a0 e8        jrc ra
