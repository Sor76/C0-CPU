.section .text
.global _start

.macro NOP_SEQ
    nop
    nop
    nop
.endm

.macro PUSH rs
    sw \rs, 0(sp)
    addi sp, sp, -16
.endm
.macro PEEK rd
    lw \rd, 16(sp)
.endm
.macro POP rd
    PEEK \rd
    addi sp, sp, 16
.endm

.macro BAD_CALL label
1:  auipc ra, %pcrel_hi(\label)
    NOP_SEQ
    jalr ra, (%pcrel_lo(1b))(ra)
.endm
.macro BAD_LA rd, target
1:  auipc \rd, %pcrel_hi(\target)
    NOP_SEQ
    addi \rd, \rd, %pcrel_lo(1b)
.endm

.macro WRITE_TO_LCD instruction
    addi a0, zero, \instruction
    NOP_SEQ
    jal ra, write_lcd
    NOP_SEQ
.endm

_start:
    BAD_LA sp, _stack_top
    BAD_LA s0, _lcd_origin
    BAD_LA s1, _button_origin
    jal ra, wait_ram_reset
    NOP_SEQ

    jal ra, set_up_lcd
    NOP_SEQ

    jal ra, main_loop
    NOP_SEQ

    j exit_loop
    NOP_SEQ

counter:
    # a0 = target number
    # t0 = current number
    addi t0, zero, 0
    NOP_SEQ

    1:
        bge t0, a0, 2f
        NOP_SEQ
        addi t0, t0, 10
        j 1b
        NOP_SEQ
    2:
        ret
        NOP_SEQ

wait_ram_reset:
    li a0, 32768
    PUSH ra
    jal ra, counter
    NOP_SEQ
    POP ra
    NOP_SEQ
    ret
    NOP_SEQ

write_lcd:
    # a0 = 65536 (for delay between stage)
    # s0 = lcd address
    # t0 = writing data
    # t1 = t0 with e signal high
    PUSH ra
    mv t0, a0
    ori t1, a0, 0x200
    li a0, 65536
    PUSH t0

    # Write / Prep
    sw t0, 0(s0)
    jal ra, counter
    NOP_SEQ
    PEEK t0

    # Send
    sw t1, 0(s0)
    jal ra, counter
    NOP_SEQ
    POP t0

    # Hold
    # sw t0, 0(s0)
    sw zero, 0(s0)
    jal ra, counter
    NOP_SEQ

    POP ra
    NOP_SEQ
    ret
    NOP_SEQ

set_up_lcd:
    PUSH ra

    WRITE_TO_LCD 0x038
    WRITE_TO_LCD 0x00C
    WRITE_TO_LCD 0x001
    WRITE_TO_LCD 0x006

    POP ra
    NOP_SEQ
    ret
    NOP_SEQ

main_loop:
    # t0 = New data from Button Controller
    # t1 = Previous data from Button Controller
    # t2 = Data to be written to LCD
    # t3 = Data for comparing
    # s1 = Button Controller Address
    li t1, 0
    BAD_LA t4, _button_origin
    NOP_SEQ
    PUSH t1

    # Display "C0 CPU"
    WRITE_TO_LCD 0x143
    WRITE_TO_LCD 0x130

    WRITE_TO_LCD 0x120
    
    WRITE_TO_LCD 0x143
    WRITE_TO_LCD 0x150
    WRITE_TO_LCD 0x155

    WRITE_TO_LCD 0x0C0                  # 2nd line

    # Read button / new value validation
    1:
        POP t1
        lw t0, 0(s1)
        NOP_SEQ
        PUSH t0

        beq t0, t1, 1b                  # Go back if the read data is the same (prev register is still not updated)
        beq t0, zero, 1b                # Go back if no buttons are pressed
        NOP_SEQ

    # Button value branching wall
    #  c <- % /
    #  7  8 9 x
    #  4  5 6 -
    #  1  2 3 +
    # 00  0 . =

    li t3, 1
    li t3, 2
    li t3, 3
    beq t0, t3, c
    beq t0, t3, del
    beq t0, t3, per

    li t3, 4
    li t3, 5
    li t3, 6
    beq t0, t3, div
    beq t0, t3, num_7
    beq t0, t3, num_8

    li t3, 7
    li t3, 8
    li t3, 9
    beq t0, t3, num_9
    beq t0, t3, mul
    beq t0, t3, num_4
    
    li t3, 10
    li t3, 11
    li t3, 12
    beq t0, t3, num_5
    beq t0, t3, num_6
    beq t0, t3, sub

    li t3, 13
    li t3, 14
    li t3, 15
    beq t0, t3, num_1
    beq t0, t3, num_2
    beq t0, t3, num_3

    li t3, 16
    li t3, 17
    li t3, 18
    beq t0, t3, add
    beq t0, t3, num_00
    beq t0, t3, num_0

    li t3, 19
    li t3, 20
    nop
    beq t0, t3, point
    beq t0, t3, equal
    NOP_SEQ

    c:
        WRITE_TO_LCD 0x1F3
        j 1b
        NOP_SEQ
    del:
        j 1b
        NOP_SEQ
    per:
        WRITE_TO_LCD 0x125
        j 1b
        NOP_SEQ
    div:
        WRITE_TO_LCD 0x1FD
        j 1b
        NOP_SEQ
    num_7:
        WRITE_TO_LCD 0x137
        j 1b
        NOP_SEQ
    num_8:
        WRITE_TO_LCD 0x138
        j 1b
        NOP_SEQ
    num_9:
        WRITE_TO_LCD 0x139
        j 1b
        NOP_SEQ
    mul:
        WRITE_TO_LCD 0x12A
        j 1b
        NOP_SEQ
    num_4:
        WRITE_TO_LCD 0x134
        j 1b
        NOP_SEQ
    num_5:
        WRITE_TO_LCD 0x135
        j 1b
        NOP_SEQ
    num_6:
        WRITE_TO_LCD 0x136
        j 1b
        NOP_SEQ
    sub:
        WRITE_TO_LCD 0x12D
        j 1b
        NOP_SEQ
    num_1:
        WRITE_TO_LCD 0x131
        j 1b
        NOP_SEQ
    num_2:
        WRITE_TO_LCD 0x132
        j 1b
        NOP_SEQ
    num_3:
        WRITE_TO_LCD 0x133
        j 1b
        NOP_SEQ
    add:
        WRITE_TO_LCD 0x12B
        j 1b
        NOP_SEQ
    num_00:
        WRITE_TO_LCD 0x130
        WRITE_TO_LCD 0x130
        j 1b
        NOP_SEQ
    num_0:
        WRITE_TO_LCD 0x130
        j 1b
        NOP_SEQ
    point:
        WRITE_TO_LCD 0x12E
        j 1b
        NOP_SEQ
    equal:
        WRITE_TO_LCD 0x13D
        j 1b
        NOP_SEQ

exit_loop:
    j exit_loop
    NOP_SEQ
