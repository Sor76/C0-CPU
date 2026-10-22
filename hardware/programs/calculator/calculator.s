.section .text
.global _start

.macro NOP_SEQ
    nop
    nop
    nop
.endm

.macro PUSH rs
    addi sp, sp, -16
    sw \rs, 0(sp)
.endm
.macro PEEK rd
    lw \rd, 16(sp)
.endm
.macro POP rd
    addi sp, sp, 16
    PEEK \rd
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

.macro WRITE_TO_LCD register, immediate
    addi a0, \register, \immediate
    NOP_SEQ
    jal ra, write_lcd
    NOP_SEQ
.endm

_start:
    BAD_LA sp, _stack_top
    nop
    jal ra, wait_ram_reset
    NOP_SEQ

    jal ra, set_up_lcd
    NOP_SEQ

    jal ra, main_loop
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
    # t1 = lcd address
    # t2 = writing data
    # t3 = t2 with e signal high
    li a0, 65536
    mv t2, a0
    ori t3, a0, 0x200
    BAD_LA t1, _lcd_origin
    PUSH ra

    # Write / Prep
    sw t2, 0(t1)
    jal ra, counter
    NOP_SEQ

    # Send
    sw t3, 0(t1)
    jal ra, counter
    NOP_SEQ

    # Hold
    sw t2, 0(t1)
    jal ra, counter
    NOP_SEQ

    POP ra
    NOP_SEQ
    ret
    NOP_SEQ


set_up_lcd:
    PUSH ra

    WRITE_TO_LCD zero, 0x38
    WRITE_TO_LCD zero, 0x0C
    WRITE_TO_LCD zero, 0x01
    WRITE_TO_LCD zero, 0x06

    POP ra
    NOP_SEQ
    ret
    NOP_SEQ

main_loop:
    # t0 = Data from Button Controller
    # t4 = Button Controller Address
    # t5 = Constant for comparing
    BAD_LA t4, _button_origin
    li t5, 0x9

    # Display "C0 CPU"
    WRITE_TO_LCD zero, 0x143
    WRITE_TO_LCD zero, 0x130

    WRITE_TO_LCD zero, 0x120
    
    WRITE_TO_LCD zero, 0x143
    WRITE_TO_LCD zero, 0x150
    WRITE_TO_LCD zero, 0x155

    # Read Button - LCD Write loop
    1:
        WRITE_TO_LCD zero, 0x0C0
        lw t0, 0(t4)
        NOP_SEQ
        bgt t0, t5, more_than_9
        NOP_SEQ

    less_eq_than_9:
        WRITE_TO_LCD t0, 0x130
        j 1b
        NOP_SEQ

    more_than_9:
        WRITE_TO_LCD t0, 0x137
        j 1b
        NOP_SEQ
        
    j 1b
    NOP_SEQ
