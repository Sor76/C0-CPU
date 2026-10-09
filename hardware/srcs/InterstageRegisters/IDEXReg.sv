`timescale 1ns/1ps

module IDEXReg
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic       clk,
    input   logic       rst_n,

    input   Word        extended_imm,
    input   Word        rs2_data,
    input   Word        address,
    input   Word        rs1_data,
    input   logic [1:0] alu_operand,
    input   ALUOp       alu_op,
    input   ComOp       com_op,
    input   JmpOp       jmp_op,
    input   ReadOp      read_op,
    input   WriteOp     write_op,
    input   rdSrc       rd_src,
    input   RegAddr     rd_addr,
    input   rdWrite     rd_write,

    output  Word        extended_imm_register,
    output  Word        rs2_data_register,
    output  Word        address_register,
    output  Word        rs1_data_register,
    output  logic [1:0] alu_operand_register,
    output  ALUOp       alu_op_register,
    output  ComOp       com_op_register,
    output  JmpOp       jmp_op_register,
    output  ReadOp      read_op_register,
    output  WriteOp     write_op_register,
    output  rdSrc       rd_src_register,
    output  RegAddr     rd_addr_register,
    output  rdWrite     rd_write_register
);
    assign rs1_data_register = rs1_data;
    assign rs2_data_register = rs2_data;
    initial begin
        extended_imm_register   = Word'('0);
        address_register        = Word'('0);
        alu_operand_register    = 2'b00;
        alu_op_register         = ADD;
        com_op_register         = EQ;
        jmp_op_register         = NO_JUMP;
        read_op_register        = NO_READ_OP;
        write_op_register       = NO_WRITE_OP;
        rd_src_register         = RDSRC_ALU_RESULT;
        rd_addr_register        = RegAddr'('0);
        rd_write_register       = NO_RD_WRITE;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            extended_imm_register   <= Word'('0);
            address_register        <= Word'('0);
            alu_operand_register    <= 2'b00;
            alu_op_register         <= ADD;
            com_op_register         <= EQ;
            jmp_op_register         <= NO_JUMP;
            read_op_register        <= NO_READ_OP;
            write_op_register       <= NO_WRITE_OP;
            rd_src_register         <= RDSRC_ALU_RESULT;
            rd_addr_register        <= RegAddr'('0);
            rd_write_register       <= NO_RD_WRITE;
        end else begin
            extended_imm_register   <= extended_imm;
            address_register        <= address;
            alu_operand_register    <= alu_operand;
            alu_op_register         <= alu_op;
            com_op_register         <= com_op;
            jmp_op_register         <= jmp_op;
            read_op_register        <= read_op;
            write_op_register       <= write_op;
            rd_src_register         <= rd_src;
            rd_addr_register        <= rd_addr;
            rd_write_register       <= rd_write;
        end
    end
endmodule