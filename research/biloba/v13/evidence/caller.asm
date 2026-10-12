0130d904  9130d904  f5 64        save 40, ra, s0, s1
0130d906  9130d906  02 f0 00 6c  li a0, 0x1000
0130d90a  9130d90a  47 b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d90c  9130d90c  81 f0 0d 6e  li a2, 0x88d
0130d910  9130d910  a1 18 9d 41  jal 0x90950674
0130d914  9130d914  00 65        nop
0130d916  9130d916  02 67        move s0, v0
0130d918  9130d918  04 2a        bnez v0, 0x9130d922
0130d91a  9130d91a  43 b4        lw a0, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d91c  9130d91c  81 f0 0f 6d  li a1, 0x88f
0130d920  9130d920  05 ea        break 16
0130d922  9130d922  42 b5        lw a1, [0x9130da28] ; =0x91523840 'lcsh custom_nvram_read_and_check_signed_critical_data'
0130d924  9130d924  40 19 bc 62  jal 0x90298af0
0130d928  9130d928  02 6c        li a0, 0x2
0130d92a  9130d92a  82 19 c0 35  jal 0x9130d700
0130d92e  9130d92e  00 65        nop
0130d930  9130d930  09 2a        bnez v0, 0x9130d944
0130d932  9130d932  3d b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d934  9130d934  81 f0 15 6e  li a2, 0x895
0130d938  9130d938  a1 18 a0 41  jal 0x90950680
0130d93c  9130d93c  90 67        move a0, s0
0130d93e  9130d93e  02 6c        li a0, 0x2
0130d940  9130d940  3b b5        lw a1, [0x9130da2c] ; =0x91523878 'lcsh skip IMEI check'
0130d942  9130d942  2c 10        b 0x9130d99c
0130d944  9130d944  1d f7 10 6c  li a0, 0xef10
0130d948  9130d948  01 6d        li a1, 0x1
0130d94a  9130d94a  d0 67        move a2, s0
0130d94c  9130d94c  e1 19 bf 10  jal 0x90bc42fc
0130d950  9130d950  0a 6f        li a3, 0xa
0130d952  9130d952  01 72        cmpi v0, 0x1
0130d954  9130d954  09 60        bteqz 0x9130d968
0130d956  9130d956  34 b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d958  9130d958  81 f0 1e 6e  li a2, 0x89e
0130d95c  9130d95c  a1 18 a0 41  jal 0x90950680
0130d960  9130d960  90 67        move a0, s0
0130d962  9130d962  02 6c        li a0, 0x2
0130d964  9130d964  33 b5        lw a1, [0x9130da30] ; =0x91523890 'custom_nvram_read_and_check_signed_critical_data read imei fail'
0130d966  9130d966  49 10        b 0x9130d9fa
0130d968  9130d968  30 67        move s1, s0
0130d96a  9130d96a  00 f0 8a 40  addiu a0, s0, 10
0130d96e  9130d96e  50 67        move v0, s0
0130d970  9130d970  ff 6b        li v1, 0xff
0130d972  9130d972  a0 a2        lbu a1, 0(v0)
0130d974  9130d974  01 4a        addiu v0, 1
0130d976  9130d976  8a ea        cmp v0, a0
0130d978  9130d978  ac eb        and v1, a1
0130d97a  9130d97a  fb 61        btnez 0x9130d972
0130d97c  9130d97c  82 19 2e 36  jal 0x9130d8b8
0130d980  9130d980  05 d3        sw v1, 20(sp)
0130d982  9130d982  01 72        cmpi v0, 0x1
0130d984  9130d984  13 60        bteqz 0x9130d9ac
0130d986  9130d986  05 93        lw v1, 20(sp)
0130d988  9130d988  ff 73        cmpi v1, 0xff
0130d98a  9130d98a  0c 61        btnez 0x9130d9a4
0130d98c  9130d98c  26 b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d98e  9130d98e  a1 f0 0d 6e  li a2, 0x8ad
0130d992  9130d992  a1 18 a0 41  jal 0x90950680
0130d996  9130d996  90 67        move a0, s0
0130d998  9130d998  02 6c        li a0, 0x2
0130d99a  9130d99a  27 b5        lw a1, [0x9130da34] ; =0x915238d0 'custom_nvram_read_and_check_signed_critical_data imei is default value, bypass check'
0130d99c  9130d99c  40 19 bc 62  jal 0x90298af0
0130d9a0  9130d9a0  01 69        li s1, 0x1
0130d9a2  9130d9a2  3c 10        b 0x9130da1c
0130d9a4  9130d9a4  25 b5        lw a1, [0x9130da38] ; =0x91523928 'custom_nvram_read_and_check_signed_critical_data is factory or old boardid'
0130d9a6  9130d9a6  40 19 bc 62  jal 0x90298af0
0130d9aa  9130d9aa  02 6c        li a0, 0x2
0130d9ac  9130d9ac  c1 f0 01 6c  li a0, 0x8c1
0130d9b0  9130d9b0  01 6d        li a1, 0x1
0130d9b2  9130d9b2  02 f0 00 6f  li a3, 0x1000
0130d9b6  9130d9b6  e1 19 bf 10  jal 0x90bc42fc
0130d9ba  9130d9ba  d0 67        move a2, s0
0130d9bc  9130d9bc  01 72        cmpi v0, 0x1
0130d9be  9130d9be  04 61        btnez 0x9130d9c8
0130d9c0  9130d9c0  02 f0 60 40  addiu v1, s0, 4096
0130d9c4  9130d9c4  00 6a        li v0, 0x0
0130d9c6  9130d9c6  09 10        b 0x9130d9da
0130d9c8  9130d9c8  17 b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d9ca  9130d9ca  a1 f0 17 6e  li a2, 0x8b7
0130d9ce  9130d9ce  a1 18 a0 41  jal 0x90950680
0130d9d2  9130d9d2  90 67        move a0, s0
0130d9d4  9130d9d4  02 6c        li a0, 0x2
0130d9d6  9130d9d6  1a b5        lw a1, [0x9130da3c] ; =0x91523974 'custom_nvram_read_and_check_signed_critical_data read critical data fail'
0130d9d8  9130d9d8  10 10        b 0x9130d9fa
0130d9da  9130d9da  6a e9        cmp s1, v1
0130d9dc  9130d9dc  04 60        bteqz 0x9130d9e6
0130d9de  9130d9de  80 a1        lbu a0, 0(s1)
0130d9e0  9130d9e0  01 49        addiu s1, 1
0130d9e2  9130d9e2  8d ea        or v0, a0
0130d9e4  9130d9e4  fa 17        b 0x9130d9da
0130d9e6  9130d9e6  90 67        move a0, s0
0130d9e8  9130d9e8  0c 2a        bnez v0, 0x9130da02
0130d9ea  9130d9ea  0f b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130d9ec  9130d9ec  c1 f0 03 6e  li a2, 0x8c3
0130d9f0  9130d9f0  a1 18 a0 41  jal 0x90950680
0130d9f4  9130d9f4  00 65        nop
0130d9f6  9130d9f6  02 6c        li a0, 0x2
0130d9f8  9130d9f8  12 b5        lw a1, [0x9130da40] ; =0x915239c0 'custom_nvram_read_and_check_signed_critical_data sign data is default value, check fail'
0130d9fa  9130d9fa  40 19 bc 62  jal 0x90298af0
0130d9fe  9130d9fe  00 69        li s1, 0x0
0130da00  9130da00  0d 10        b 0x9130da1c
0130da02  9130da02  02 f0 00 6d  li a1, 0x1000
0130da06  9130da06  82 19 6e 34  jal 0x9130d1b8
0130da0a  9130da0a  01 6e        li a2, 0x1
0130da0c  9130da0c  01 5a        sltiu v0, 1
0130da0e  9130da0e  90 67        move a0, s0
0130da10  9130da10  05 b5        lw a1, [0x9130da24] ; =0x9152308c 'pcore/custom/service/nvram/custom_nvram_sec.c'
0130da12  9130da12  c1 f0 0e 6e  li a2, 0x8ce
0130da16  9130da16  a1 18 a0 41  jal 0x90950680
0130da1a  9130da1a  38 67        move s1, t8
0130da1c  9130da1c  51 67        move v0, s1
0130da1e  9130da1e  75 64        restore 40, ra, s0, s1
0130da20  9130da20  a0 e8        jrc ra
