`timescale 1ns/1ps

module OperationDecoder
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input   logic [19:0]    raw_imm,
    input   logic [6:0]     opcode,
    input   logic [2:0]     funct3,
    input   logic [6:0]     funct7,

    output  logic [1:0]     alu_operand,
    output  ALUOp           alu_op,
    output  ComOp           com_op,
    output  JmpOp           jmp_op,
    output  ReadOp          read_op,
    output  WriteOp         write_op,
    output  rdSrc           rd_src,
    output  rdWrite         rd_write
);
    logic funct7_bit;
    logic special_imm_bit;
    assign funct7_bit = funct7[5];
    assign special_imm_bit = raw_imm[5];

    always_comb begin
        case (opcode)
            7'b0110011: begin
                // R-type Arithmetic and Logic
                alu_operand = 2'b00;
                alu_op      = ALUOp'({funct7_bit, funct3});
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            7'b0010011: begin
                // I-type Arithmetic and Logic
                alu_operand = 2'b10;
                case (funct3)
                    3'b101: alu_op = ALUOp'({special_imm_bit, funct3});
                    default: alu_op = ALUOp'(funct3);
                endcase
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            7'b0000011: begin
                // Load
                alu_operand = 2'b10;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = ReadOp'(funct3);
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_DEVICE_READ_DATA;
                rd_write    = RD_WRITE;
            end
            7'b0100011: begin
                // Store
                alu_operand = 2'b10;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = NO_READ_OP;
                write_op    = WriteOp'(funct3[1:0]);
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = NO_RD_WRITE;
            end
            7'b1100011: begin
                // Branch
                alu_operand = 2'b11;
                alu_op      = ADD;
                com_op      = ComOp'(funct3);
                jmp_op      = BRANCH;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = NO_RD_WRITE;
            end
            7'b1101111: begin
                // JAL
                alu_operand = 2'b11;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = JAL;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_NEXT_ADDRESS;
                rd_write    = RD_WRITE;
            end
            7'b1100111: begin
                // JALR
                alu_operand = 2'b10;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = JALR;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_NEXT_ADDRESS;
                rd_write    = RD_WRITE;
            end
            7'b0110111: begin
                // LUI
                alu_operand = 2'b10;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            7'b0010111: begin
                // AUIPC
                alu_operand = 2'b11;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            default: begin
                // Default to NOP operation (addi zero, zero, 0)
                alu_operand = 2'b00;
                alu_op      = ADD;
                com_op      = EQ;
                jmp_op      = NO_JUMP;
                read_op     = NO_READ_OP;
                write_op    = NO_WRITE_OP;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = NO_RD_WRITE;
            end
        endcase
    end
    
endmodule