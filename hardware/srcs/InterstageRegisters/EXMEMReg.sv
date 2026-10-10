`timescale 1ns/1ps

module EXMEMReg
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic   clk,
    input   logic   rst_n,

    input   PCSrc   pc_src,
    input   Word    alu_result,
    input   Word    next_address,
    input   Word    rs2_data,
    input   ReadOp  read_op,
    input   WriteOp write_op,
    input   rdSrc   rd_src,
    input   RegAddr rd_addr,
    input   rdWrite rd_write,

    output  PCSrc   pc_src_register,
    output  Word    alu_result_register,
    output  Word    next_address_register,
    output  Word    rs2_data_register,
    output  ReadOp  read_op_register,
    output  WriteOp write_op_register,
    output  rdSrc   rd_src_register,
    output  RegAddr rd_addr_register,
    output  rdWrite rd_write_register
);
    initial begin
        pc_src_register         = PCSRC_NEXT_ADDRESS;
        alu_result_register     = '0;
        next_address_register   = '0;
        rs2_data_register       = '0;
        read_op_register        = NO_READ_OP;
        write_op_register       = NO_WRITE_OP;
        rd_src_register         = RDSRC_ALU_RESULT;
        rd_addr_register        = RegAddr'('0);
        rd_write_register       = NO_RD_WRITE;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pc_src_register         <= PCSRC_NEXT_ADDRESS;
            alu_result_register     <= '0;
            next_address_register   <= '0;
            rs2_data_register       <= '0;
            read_op_register        <= NO_READ_OP;
            write_op_register       <= NO_WRITE_OP;
            rd_src_register         <= RDSRC_ALU_RESULT;
            rd_addr_register        <= RegAddr'('0);
            rd_write_register       <= NO_RD_WRITE;
        end else begin
            pc_src_register         <= pc_src;
            alu_result_register     <= alu_result;
            next_address_register   <= next_address;
            rs2_data_register       <= rs2_data;
            read_op_register        <= read_op;
            write_op_register       <= write_op;
            rd_src_register         <= rd_src;
            rd_addr_register        <= rd_addr;
            rd_write_register       <= rd_write;
        end
    end
endmodule