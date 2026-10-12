0130d700  9130d700  f0 64        save 128, ra, s0, s1
0130d702  9130d702  20 6e        li a2, 0x20
0130d704  9130d704  0c 04        addiu a0, sp, 48
0130d706  9130d706  a1 18 5f 40  jal 0x9095017c
0130d70a  9130d70a  00 6d        li a1, 0x0
0130d70c  9130d70c  7d 67        move v1, sp
0130d70e  9130d70e  00 6a        li v0, 0x0
0130d710  9130d710  4b ea        neg v0, v0
0130d712  9130d712  02 6c        li a0, 0x2
0130d714  9130d714  53 b5        lw a1, [0x9130d860] ; =0x91523550 'lcsh is_need_enable_critical_data_check'
0130d716  9130d716  40 19 bc 62  jal 0x90298af0
0130d71a  9130d71a  5c c3        sb v0, 28(v1)
0130d71c  9130d71c  82 19 37 34  jal 0x9130d0dc
0130d720  9130d720  0c 04        addiu a0, sp, 48
0130d722  9130d722  01 52        slti v0, 1
0130d724  9130d724  02 60        bteqz 0x9130d72a
0130d726  9130d726  00 6a        li v0, 0x0
0130d728  9130d728  98 10        b 0x9130d85a
0130d72a  9130d72a  02 6c        li a0, 0x2
0130d72c  9130d72c  4e b5        lw a1, [0x9130d864] ; =0x91523578 'lcsh get product name:%s'
0130d72e  9130d72e  40 19 bc 62  jal 0x90298af0
0130d732  9130d732  0c 06        addiu a2, sp, 48
0130d734  9130d734  0c 04        addiu a0, sp, 48
0130d736  9130d736  4d b5        lw a1, [0x9130d868] ; =0x91523594 'secret'
0130d738  9130d738  82 1d a6 99  jalx 0x91326698
0130d73c  9130d73c  06 6e        li a2, 0x6
0130d73e  9130d73e  18 22        beqz v0, 0x9130d770
0130d740  9130d740  0c 04        addiu a0, sp, 48
0130d742  9130d742  4b b5        lw a1, [0x9130d86c] ; =0x9152359c 'rosemary'
0130d744  9130d744  82 1d a6 99  jalx 0x91326698
0130d748  9130d748  08 6e        li a2, 0x8
0130d74a  9130d74a  12 22        beqz v0, 0x9130d770
0130d74c  9130d74c  0c 04        addiu a0, sp, 48
0130d74e  9130d74e  49 b5        lw a1, [0x9130d870] ; =0x915235a8 'maltose'
0130d750  9130d750  82 1d a6 99  jalx 0x91326698
0130d754  9130d754  07 6e        li a2, 0x7
0130d756  9130d756  0c 22        beqz v0, 0x9130d770
0130d758  9130d758  0c 04        addiu a0, sp, 48
0130d75a  9130d75a  47 b5        lw a1, [0x9130d874] ; =0x915235b0 'pending'
0130d75c  9130d75c  82 1d a6 99  jalx 0x91326698
0130d760  9130d760  07 6e        li a2, 0x7
0130d762  9130d762  06 22        beqz v0, 0x9130d770
0130d764  9130d764  0c 04        addiu a0, sp, 48
0130d766  9130d766  45 b5        lw a1, [0x9130d878] ; =0x915235b8 'biloba'
0130d768  9130d768  82 1d a6 99  jalx 0x91326698
0130d76c  9130d76c  06 6e        li a2, 0x6
0130d76e  9130d76e  db 2a        bnez v0, 0x9130d726
0130d770  9130d770  08 04        addiu a0, sp, 32
0130d772  9130d772  43 b5        lw a1, [0x9130d87c] ; =0x915237d0 'ro.boot.hwlevel'
0130d774  9130d774  69 1e 00 80  jalx 0x94ce0000
0130d778  9130d778  10 6e        li a2, 0x10
0130d77a  9130d77a  14 04        addiu a0, sp, 80
0130d77c  9130d77c  00 6d        li a1, 0x0
0130d77e  9130d77e  a1 18 5f 40  jal 0x9095017c
0130d782  9130d782  20 6e        li a2, 0x20
0130d784  9130d784  20 6a        li v0, 0x20
0130d786  9130d786  04 d2        sw v0, 16(sp)
0130d788  9130d788  08 f0 0f 6c  li a0, 0x400f
0130d78c  9130d78c  08 05        addiu a1, sp, 32
0130d78e  9130d78e  10 6e        li a2, 0x10
0130d790  9130d790  a0 18 ef a0  jal 0x901683bc
0130d794  9130d794  14 07        addiu a3, sp, 80
0130d796  9130d796  01 52        slti v0, 1
0130d798  9130d798  07 60        bteqz 0x9130d7a8
0130d79a  9130d79a  02 6c        li a0, 0x2
0130d79c  9130d79c  39 b5        lw a1, [0x9130d880] ; =0x915235c0 'lcsh custom_nvram_get_property_value :%s, got error:%d'
0130d79e  9130d79e  08 06        addiu a2, sp, 32
0130d7a0  9130d7a0  40 19 bc 62  jal 0x90298af0
0130d7a4  9130d7a4  e2 67        move a3, v0
0130d7a6  9130d7a6  57 10        b 0x9130d856
0130d7a8  9130d7a8  1c 03        addiu v1, sp, 112
0130d7aa  9130d7aa  49 e3        addu v0, v1, v0
0130d7ac  9130d7ac  00 6b        li v1, 0x0
0130d7ae  9130d7ae  6b eb        neg v1, v1
0130d7b0  9130d7b0  02 6c        li a0, 0x2
0130d7b2  9130d7b2  35 b5        lw a1, [0x9130d884] ; =0x915235f8 'lcsh get hwlevel:%s'
0130d7b4  9130d7b4  ff f7 60 c2  sb v1, -32(v0)
0130d7b8  9130d7b8  40 19 bc 62  jal 0x90298af0
0130d7bc  9130d7bc  14 06        addiu a2, sp, 80
0130d7be  9130d7be  33 b5        lw a1, [0x9130d888] ; =0x9144426c '0'
0130d7c0  9130d7c0  82 1d 89 98  jalx 0x91326224
0130d7c4  9130d7c4  14 04        addiu a0, sp, 80
0130d7c6  9130d7c6  03 2a        bnez v0, 0x9130d7ce
0130d7c8  9130d7c8  02 6c        li a0, 0x2
0130d7ca  9130d7ca  31 b5        lw a1, [0x9130d88c] ; =0x9152360c 'lcsh is_need_enable_critical_data_check SKIP  P0'
0130d7cc  9130d7cc  41 10        b 0x9130d850
0130d7ce  9130d7ce  31 b5        lw a1, [0x9130d890] ; =0x914537c0 '1'
0130d7d0  9130d7d0  82 1d 89 98  jalx 0x91326224
0130d7d4  9130d7d4  14 04        addiu a0, sp, 80
0130d7d6  9130d7d6  0a 22        beqz v0, 0x9130d7ec
0130d7d8  9130d7d8  2f b5        lw a1, [0x9130d894] ; =0x91523640 '1.1'
0130d7da  9130d7da  82 1d 89 98  jalx 0x91326224
0130d7de  9130d7de  14 04        addiu a0, sp, 80
0130d7e0  9130d7e0  05 22        beqz v0, 0x9130d7ec
0130d7e2  9130d7e2  2e b5        lw a1, [0x9130d898] ; =0x9145efac '2'
0130d7e4  9130d7e4  82 1d 89 98  jalx 0x91326224
0130d7e8  9130d7e8  14 04        addiu a0, sp, 80
0130d7ea  9130d7ea  26 2a        bnez v0, 0x9130d838
0130d7ec  9130d7ec  2c b5        lw a1, [0x9130d89c] ; =0x91523644 'lcsh is_need_enable_critical_data_check P1 P1.1 P2+custom nv check'
0130d7ee  9130d7ee  40 19 bc 62  jal 0x90298af0
0130d7f2  9130d7f2  02 6c        li a0, 0x2
0130d7f4  9130d7f4  c1 f0 02 6c  li a0, 0x8c2
0130d7f8  9130d7f8  01 6d        li a1, 0x1
0130d7fa  9130d7fa  07 06        addiu a2, sp, 28
0130d7fc  9130d7fc  e1 19 bf 10  jal 0x90bc42fc
0130d800  9130d800  01 6f        li a3, 0x1
0130d802  9130d802  01 72        cmpi v0, 0x1
0130d804  9130d804  01 68        li s0, 0x1
0130d806  9130d806  28 61        btnez 0x9130d858
0130d808  9130d808  5d 67        move v0, sp
0130d80a  9130d80a  02 6c        li a0, 0x2
0130d80c  9130d80c  3c a2        lbu s1, 28(v0)
0130d80e  9130d80e  00 f0 61 69  andi s1, 0x1
0130d812  9130d812  05 21        beqz s1, 0x9130d81e
0130d814  9130d814  23 b5        lw a1, [0x9130d8a0] ; =0x91523688 'lcsh is_need_enable_critical_data_check sign control data is not default value, skip'
0130d816  9130d816  40 19 bc 62  jal 0x90298af0
0130d81a  9130d81a  00 68        li s0, 0x0
0130d81c  9130d81c  04 10        b 0x9130d826
0130d81e  9130d81e  22 b5        lw a1, [0x9130d8a4] ; =0x915236e0 'lcsh is_need_enable_critical_data_check chk_val=KAL_TRUE'
0130d820  9130d820  40 19 bc 62  jal 0x90298af0
0130d824  9130d824  00 65        nop
0130d826  9130d826  00 6a        li v0, 0x0
0130d828  9130d828  04 d2        sw v0, 16(sp)
0130d82a  9130d82a  02 6c        li a0, 0x2
0130d82c  9130d82c  1f b5        lw a1, [0x9130d8a8] ; =0x9152371c 'lcsh is_need_enable_critical_data_check chk_val=%d,KAL_TRUE=%d,KAL_FALSE=%d'
0130d82e  9130d82e  d1 67        move a2, s1
0130d830  9130d830  40 19 bc 62  jal 0x90298af0
0130d834  9130d834  01 6f        li a3, 0x1
0130d836  9130d836  10 10        b 0x9130d858
0130d838  9130d838  1d b5        lw a1, [0x9130d8ac] ; =0x91523790 'MP'
0130d83a  9130d83a  82 1d 89 98  jalx 0x91326224
0130d83e  9130d83e  14 04        addiu a0, sp, 80
0130d840  9130d840  02 6c        li a0, 0x2
0130d842  9130d842  05 2a        bnez v0, 0x9130d84e
0130d844  9130d844  1b b5        lw a1, [0x9130d8b0] ; =0x91523768 'lcsh is_need_enable_critical_data_check MP'
0130d846  9130d846  40 19 bc 62  jal 0x90298af0
0130d84a  9130d84a  01 68        li s0, 0x1
0130d84c  9130d84c  05 10        b 0x9130d858
0130d84e  9130d84e  1a b5        lw a1, [0x9130d8b4] ; =0x91523794 'lcsh is_need_enable_critical_data_check other hwlevel skip'
0130d850  9130d850  40 19 bc 62  jal 0x90298af0
0130d854  9130d854  00 65        nop
0130d856  9130d856  00 68        li s0, 0x0
0130d858  9130d858  50 67        move v0, s0
0130d85a  9130d85a  70 64        restore 128, ra, s0, s1
0130d85c  9130d85c  a0 e8        jrc ra
