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
    # Using register
    # s0 = button origin
    # s1 = vga origin
    #
    # s2 = current bird y position
    # s3 = Current bird y velocity
    # s4 = Min bird y velocity
    # s5 = Max bird y velocity
    # s6 = Min bird y
    # s7 = Max bird y
    #
    # s8 = Top pipe y
    # s9 = Pipe x
    # s10 = Min top pipe y
    # s11 = Max top pipe y
    #
    # t4 = Current button value / temp bird left side x value for pipe hitting check
    # t5 = Last button value / temp bird right side x value for pipe hitting check
    # t6 = Previous bird y / pop out last pipe x / immediate load for max x (10) for pipe

    mv t5, zero
    mv t6, s2

    li s2, 80
    li s3, 0
    li s4, 3
    li s5, -7
    li s6, 0
    li s7, 170

    li s8, 55
    li s9, 279
    li s10, 10
    li s11, 120

    PUSH t5
    PUSH s2
    PUSH s9

    begin:
        # Draw background
        li a0, 0
        li a1, 0
        li a2, 0b00111
        li a3, 319
        li a4, 179
        NOP_SEQ
        jal ra, draw_box
        NOP_SEQ

        update_loop:
            # Overwrite previous pipe
            # Top Pipe
            PEEK t6
            mv a1, zero
            li a2, 0b00111
            addi a0, t6, 15
            addi a3, t6, 20
            mv a4, s8
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ
            # Bottom Pipe
            POP t6
            addi a1, s8, 50
            li a2, 0b00111
            addi a0, t6, 15
            addi a3, t6, 20
            li a4, 179
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # Draw pipe
            # Top Pipe
            mv a0, s9
            mv a1, zero
            li a2, 0b00100
            addi a3, s9, 20
            mv a4, s8
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ
            # Bottom Pipe
            mv a0, s9
            addi a1, s8, 50
            li a2, 0b00100
            addi a3, s9, 20
            li a4, 179
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # Overwrite previous bird
            POP t6
            li a0, 75
            li a2, 0b00111
            li a3, 85
            mv a1, t6
            addi a4, t6, 10
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # Draw bird
            li a0, 75
            mv a1, s2
            li a2, 0b11100
            li a3, 85
            addi a4, s2, 10
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # Check if button is newly pressed.
            # If newly press go to rise_velocity_update.
            # Else, branch to fall_velocity_update.
            lbu t4, 0(s0)
            POP t5
            NOP_SEQ
            PUSH t4                                         # Push current button value. t5 will pop this out later.
            bne t5, zero, fall_velocity_update              # Previous button value is not zero aka already pressed
            NOP_SEQ
            beq t4, zero, fall_velocity_update              # Current button value is zero aka button are not pressed
            NOP_SEQ

            rise_velocity_update:
                mv s3, s5
                j update_bird_position
                NOP_SEQ

            fall_velocity_update:
                bge s3, s4, update_bird_position            # Check if velocity reach it minimum yet. If so, don't update velocity.
                NOP_SEQ
                addi s3, s3, 1
                NOP_SEQ

            update_bird_position:
                PUSH s2                                     # Update previous bird y position. t6 will pop this out.
                add s2, s2, s3                              # Update y with velocity directly
                NOP_SEQ

                # Check if the bird is out of play border. If so, game over.
                bge s2, s7, game_over_pause
                NOP_SEQ
                ble s2, s6, game_over_pause
                NOP_SEQ
                
                # Check if the bird is hitting the pipe
                addi t0, s9, 20                             # Right side of the pipe
                li t4, 75                                   # Bird left side x value
                li t5, 85                                   # Bird right side x value
                NOP_SEQ
                blt t0, t4, update_pipe_position            # Pipe already pass the bird
                NOP_SEQ
                bge s9, t5, update_pipe_position            # Pipe doesn't reach the bird yet
                NOP_SEQ

                addi t4, s2, 10                             # Bird bottom's y value
                addi t5, s8, 50                             # Bottom pipe's y value
                ble s2, s8, game_over_pause                 # Bird is overlapping the top pipe
                NOP_SEQ
                bge t4, t5, game_over_pause                 # Bird is overlapping the bottom pipe
                NOP_SEQ

            update_pipe_position:
                PUSH s9                                         # Record current position. t6 will pop this out when overwritting.
                addi s9, s9, -3

                # Check if the pipe have reach the left part of the screen
                li t6, 10
                NOP_SEQ
                bgt s9, t6, 2f                                  # Skip new pipe generating if not in the deleting zone yet.
                NOP_SEQ
                li s9, 279

                # Overwrite the pipe
                # Top Pipe
                PEEK t6
                NOP_SEQ
                mv a0, t6
                mv a1, zero
                li a2, 0b00111
                addi a3, t6, 20
                mv a4, s8
                NOP_SEQ
                jal ra, draw_box
                NOP_SEQ
                # Bottom Pipe
                POP t6
                NOP_SEQ
                mv a0, t6
                addi a1, s8, 50
                li a2, 0b00111
                addi a3, t6, 20
                li a4, 179
                NOP_SEQ
                jal ra, draw_box
                NOP_SEQ

                PUSH s9                                         # Push the original s9 (when the program start) back.
                2:

            # Pause for roughly 42 miliseconds per each frame
            li a0, 2097152
            jal ra, counter
            NOP_SEQ

            j update_loop
            NOP_SEQ

        game_over_pause:
            # Pause for roughly 1 sec
            li a0, 67108864
            jal ra, counter
            NOP_SEQ

            # Draw red background
            li a0, 0
            li a1, 0
            li a2, 0b11000
            li a3, 319
            li a4, 179
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # LOL TEXT
            # First L
            li a0, 10
            li a1, 10
            li a2, 0b00000
            li a3, 20
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            li a0, 20
            li a1, 159
            li a2, 0b00000
            li a3, 80
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # O
            li a0, 100
            li a1, 10
            li a2, 0b00000
            li a3, 110
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            li a0, 110
            li a1, 10
            li a2, 0b00000
            li a3, 209
            li a4, 20
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            li a0, 110
            li a1, 159
            li a2, 0b00000
            li a3, 209
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            li a0, 209
            li a1, 10
            li a2, 0b00000
            li a3, 219
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            # Last L
            li a0, 239
            li a1, 10
            li a2, 0b00000
            li a3, 249
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            li a0, 249
            li a1, 159
            li a2, 0b00000
            li a3, 309
            li a4, 169
            NOP_SEQ
            jal ra, draw_box
            NOP_SEQ

            game_over_loop:
                # Check if button is newly pressed.
                # If newly press back to the main loop
                # Else, continue to stuck in this cycle
                lbu t4, 0(s0)
                POP t5                                          # Read previous button value from previous loop and from the update loop.
                NOP_SEQ
                PUSH t4                                         # Push current button value. t5 will pop this out later.
                NOP_SEQ
                bne t5, zero, game_over_loop                    # Previous button value is not zero aka already pressed
                NOP_SEQ
                beq t4, zero, game_over_loop                    # Current button value is zero aka button are not pressed
                NOP_SEQ

                POP zero                                        # Pop out last button value
                j main_loop
                NOP_SEQ

            j exit_loop
            NOP_SEQ

    j exit_loop
    NOP_SEQ

    draw_box:
        # Input arguments
        # a0 = start x
        # a1 = start y
        # a2 = colour
        # a3 = max x
        # a4 = max y
        #
        # Using registers for processing
        # a0 = current x
        # a1 = current y
        # a2 = colour
        # t4 = start x
        # t5 = max x
        # t6 = max y

        PUSH ra

        mv t4, a0
        mv t5, a3
        addi t6, a4, 1                  # +1 quirk

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
        mv a0, t4
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
