; =======================
; Waiting for the Data Memory to reset
; =======================
lui t0, 16          ; Load 65,536 (Cycle to reset 2^16 memory cell)
addi zero, zero, 0  ; Wait before add 9 to the same register
addi zero, zero, 0
addi zero, zero, 0
addi t0, t0, 9      ; Compensate the first + 9, Inst no. 5

addi t1, t1, 9      ; Add 9 to counter (self + 3 nop + branch + 4 nop)
addi zero, zero, 0
addi zero, zero, 0
addi zero, zero, 0
blt t1, t0, -8      ; Jump back to the addi 3 if less than 65,536 (shift left once to get -16)
addi zero, zero, 0  ; Wait for program counter to jump or not
addi zero, zero, 0
addi zero, zero, 0
addi zero, zero, 0  ; Inst no. 14

; =======================
; Preparing data
; =======================
; t0 = LCD Controller address
; t1 = Button Controller address
; t2 = LCD Base symbol (0)
; t3 = LCD Base symbol (A)
; t4 = Constant value for comparing (10)
; t5 = Data from Button Controller
; t6 = Data for transfering from Button -> Data Memory -> some op -> LCD

lui t0, 0x40000     ; LCD Controller address
lui t1, 0x80000     ; Button Controller address
addi t2, t2, 0x30   ; LCD Symbol base value for first 10 values (0x30 = 0)
addi t3, t3, 0x41   ; LCD Symbol base value for last 10 values (0x41 = A)
addi t4, t4, 0xA    ; Value for comparing if Button data is more than 10, Inst no. 19

; =======================
; Reading Button data
; =======================
lw t5, 0(t1)        ; Load data from Button Controller to t4 register
addi zero, zero, 0  ; Waiting for the data to arrive
addi zero, zero, 0
addi zero, zero, 0
bge t4, t5, 22      ; Branch to + t2 if value is less than 9 else + t3
addi zero, zero, 0  ; Wait for program counter to jump or not
addi zero, zero, 0
addi zero, zero, 0
addi zero, zero, 0
add t6, t5, t3      ; Value more than 9
beq zero, zero, 18  ; Jump to Data Memory section. Can't use jal cuz the range is too big.
addi zero, zero, 0  ; Wait for program counter to jump
addi zero, zero, 0
addi zero, zero, 0
addi zero, zero, 0
add t6, t5, t2      ; Value less than 9
addi zero, zero, 0  ; Waiting for add to finish
addi zero, zero, 0
addi zero, zero, 0  ; Inst no. 38

; =======================
; Writing data to Data Memory for fun
; =======================
sh t6, 1(zero)
xori t6, t6, 0xFFF  ; Not operation on the t6
addi zero, zero, 0  ; Waiting for xor to overwrite t6
addi zero, zero, 0
addi zero, zero, 0
lh t6, 1(zero)      ; Load the original data of t6 back
addi zero, zero, 0  ; Wait for data to arrive at the register file, Inst no. 45
addi zero, zero, 0  ;
addi zero, zero, 0  ;

; =======================
; Writing data to LCD (not working)
; =======================
sw t6, 0(t0)
beq zero, zero, -58 ; Jump back to top of reading Button data section. Same reason as line 50 for using branch.
addi zero, zero, 0  ; Wait for program counter to jump
addi zero, zero, 0
addi zero, zero, 0
addi zero, zero, 0  ; Inst no. 51