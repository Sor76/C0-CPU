`timescale 1ns/1ps

module ControlUnit
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
    import Types_pkg::*;
(
    input   Word            instruction,

    output  logic [19:0]    raw_imm,
    output  InstFormat      inst_format,
    output  RegAddr         rs1_addr,
    output  RegAddr         rs2_addr,
    output  RegAddr         rd_addr,

    output  logic [1:0]     alu_operand,
    output  ALUOp           alu_op,
    output  ComOp           com_op,
    output  JmpOp           jmp_op,
    output  ReadOp          read_op,
    output  WriteOp         write_op,
    output  rdSrc           rd_src,
    output  rdWrite         rd_write
);
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    InstructionDecoder inst_decoder (
        .instruction(instruction),

        .raw_imm(raw_imm),
        .inst_format(inst_format),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),

        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7)
    );
    OperationDecoder op_decoder (
        .raw_imm(raw_imm),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .alu_operand(alu_operand),
        .alu_op(alu_op),
        .com_op(com_op),
        .jmp_op(jmp_op),
        .read_op(read_op),
        .write_op(write_op),
        .rd_src(rd_src),
        .rd_write(rd_write)
    );
endmodule