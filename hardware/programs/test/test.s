/*
=======================
Waiting for the Data Memory to reset
=======================
*/
li t0, 65536            # Load 65,536 (Cycle to reset 2^16 memory cell)
nop                     # Wait before add 9 to the same register
nop
nop
addi t0, t0, 9          # Compensate the first + 9, Inst no. 5

addi t1, t1, 9          # Add 9 to counter (self + 3 nop + branch + 4 nop)
nop
nop
nop
blt t1, t0, . - 16      # Jump back to the addi 3 if less than 65,536 
nop                     # Wait for program counter to jump or not
nop
nop
nop                     # Inst no. 14

/*
=======================
Preparing data
=======================
t0 = LCD Controller address
t1 = Button Controller address
t2 = LCD Base symbol (0)
t3 = LCD Base symbol (A)
t4 = Constant value for comparing (10)
t5 = Data from Button Controller
t6 = Data for transfering from Button -> Data Memory -> some op -> LCD
*/
li t0, 0x40000000       # LCD Controller address
li t1, 0x80000000       # Button Controller address
li t2, 0x30             # LCD Symbol base value for first 10 values (0x30 = 0)
li t3, 0x41             # LCD Symbol base value for last 10 values (0x41 = A)
li t4, 0xA              # Value for comparing if Button data is more than 10, Inst no. 19

/*
=======================
Reading Button data
=======================
*/
lw t5, 0(t1)            # Load data from Button Controller to t5 register
nop                     # Waiting for the data to arrive
nop
nop
bge t4, t5, . + 44      # Branch to + t2 if value is less than 9 else + t3
nop                     # Wait for program counter to jump or not
nop
nop
nop
add t6, t5, t3          # Value more than 9
beq zero, zero, . + 36  # Jump to Data Memory section. Can't use jal cuz the range is too big.
nop                     # Wait for program counter to jump
nop
nop
nop
add t6, t5, t2          # Value less than 9
nop                     # Waiting for add to finish
nop
nop                     # Inst no. 38

/*
=======================
Writing data to Data Memory for fun
=======================
*/
sh t6, 1(zero)
xori t6, t6, -1         # Not operation on the t6
nop                     # Waiting for xor to overwrite t6
nop
nop
lh t6, 1(zero)          # Load the original data of t6 back
nop                     # Wait for data to arrive at the register file, Inst no. 45
nop                     #
nop                     #

/*
=======================
Writing data to LCD (not working)
=======================
*/
sw t6, 0(t0)
beq zero, zero, . - 116 # Jump back to top of reading Button data section. Same reason as line 50 for using branch.
nop                     # Wait for program counter to jump
nop
nop
nop                     # Inst no. 51
