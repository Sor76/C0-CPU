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
    BAD_LA s1, _direct_button_origin
    wait_ram_reset:
        li a0, 8192
        jal ra, counter
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
    # s1 = Direct Button Controller Address
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
        lbu t0, 0(s1)
        NOP_SEQ
        PUSH t0

        beq t0, t1, 1b                  # Go back if the read data is the same (prev register is still not updated)
        beq t0, zero, 1b                # Go back if no buttons are pressed
        NOP_SEQ

    li t3, 1
    li t3, 2
    li t3, 4
    beq t0, t3, top
    beq t0, t3, bottom
    beq t0, t3, left

    li t3, 8
    li t3, 16
    nop
    beq t0, t3, right
    beq t0, t3, center
    NOP_SEQ

    top:
        WRITE_TO_LCD 0x154
        j 1b
        NOP_SEQ
    bottom:
        WRITE_TO_LCD 0x142
        j 1b
        NOP_SEQ
    left:
        WRITE_TO_LCD 0x14C
        j 1b
        NOP_SEQ
    right:
        WRITE_TO_LCD 0x152
        j 1b
        NOP_SEQ
    center:
        WRITE_TO_LCD 0x143
        j 1b
        NOP_SEQ

exit_loop:
    j exit_loop
    NOP_SEQ
