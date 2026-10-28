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

.macro WRITE_TO_VGA_IMM x, y, rgb
    addi a2, zero, /rgb
    addi a1, zero, /y
    addi a0, zero, /x
    jal ra, write_lcd
    NOP_SEQ
.endm

_start:
    wait_ram_reset:
        li a0, 4096
        jal ra, counter
        NOP_SEQ

    BAD_LA sp, _stack_top
    BAD_LA s0, _direct_button_origin
    BAD_LA s1, _vga_origin

    j main_loop
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

compute_parity:
    srli t0, a0, 16
    NOP_SEQ
    xor a0, a0, t0
    NOP_SEQ

    srli t0, a0, 8
    NOP_SEQ
    xor a0, a0, t0
    NOP_SEQ

    srli t0, a0, 4
    NOP_SEQ
    xor a0, a0, t0
    NOP_SEQ

    srli t0, a0, 2
    NOP_SEQ
    xor a0, a0, t0
    NOP_SEQ

    srli t0, a0, 1
    NOP_SEQ
    xor a0, a0, t0
    NOP_SEQ

    andi a0, a0, 1
    ret
    NOP_SEQ

write_vga:
    # t0 = final data to vga (no strobe)
    # t1 = final data to vga with strobe on
    # t2 = temp register for computing mix of other fields
    # t3 = temp register for checking parity / save parity value
    li t1, 0x00800000               # Strobe

    # combining data
    mv t2, a2
    NOP_SEQ
    slli t2, t2, 8
    NOP_SEQ
    or t2, t2, a1
    NOP_SEQ
    slli t2, t2, 9
    NOP_SEQ
    or t2, t2, a0
    NOP_SEQ

    # checking parity
    PUSH ra
    mv a0, t2
    jal ra, compute_parity
    NOP_SEQ
    POP ra

    # Combining data with parity bit
    slli a0, a0, 22
    NOP_SEQ
    or t0, t2, a0                   # no strobe
    NOP_SEQ
    or t1, t1, t0                   # with strobe

    # sending pixel
    sw t0, 0(s1)
    NOP_SEQ

    sw t1, 0(s1)
    NOP_SEQ
    NOP_SEQ

    sw t0, 0(s1)
    NOP_SEQ
    
    ret
    NOP_SEQ

main_loop:
    # s0 = button origin
    # s2 = current bird y position
    # s3 = pipe x position
    # s4 = pipe hole height

    li s2, 80

    jal ra, clear_screen_loop
    NOP_SEQ
    jal ra, draw_bird
    NOP_SEQ

    j exit_loop
    NOP_SEQ

    clear_screen_loop:
        PUSH ra
        li a0, 0                        # Current pixel x
        li a1, 0                        # Current pixel y
        li a2, 0b00111                  # cyan
        li t5, 319                      # Max x
        li t6, 180                      # Max y (need + 1)

        # Draw a pixel
        1:
            PUSH a0
            NOP_SEQ
            PUSH a1

            jal ra, write_vga
            NOP_SEQ
            POP a1
            NOP_SEQ
            POP a0
            NOP_SEQ

        # Start a new line
        bne a0, t5, 2f
        NOP_SEQ
        mv a0, zero
        addi a1, a1, 1
        j 3f
        NOP_SEQ

        # Should be on the same line
        2:
            addi a0, a0, 1
            NOP_SEQ

        # Check if finish drawing the entire screen
        3:
            bne a1, t6, 1b
            NOP_SEQ
            POP ra
            NOP_SEQ
            ret
            NOP_SEQ

    draw_bird:
        PUSH ra
        li a0, 75                       # Current x pixel cordinate
        mv a1, s2                       # Current y pixel cordinate
        li a2, 0b11100                  # Orange ?
        li t5, 85                       # Max x
        addi t6, s2, 11                 # Max y

        # Draw a pixel
        1:
            PUSH a0
            NOP_SEQ
            PUSH a1

            jal ra, write_vga
            NOP_SEQ
            POP a1
            NOP_SEQ
            POP a0
            NOP_SEQ

        # Start a new line
        bne a0, t5, 2f
        NOP_SEQ
        addi a0, zero, 75
        addi a1, a1, 1
        j 3f
        NOP_SEQ

        # Should be on the same line
        2:
            addi a0, a0, 1
            NOP_SEQ

        # Check if finish drawing the entire screen
        3:
            bne a1, t6, 1b
            NOP_SEQ
            POP ra
            NOP_SEQ
            ret
            NOP_SEQ

exit_loop:
    j exit_loop
    NOP_SEQ
