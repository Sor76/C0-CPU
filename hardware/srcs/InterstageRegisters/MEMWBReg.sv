`timescale 1ns/1ps

module MEMWBReg
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic clk,
    input   logic rst_n,

    input   PCSrc           pc_src,
    input   Word            alu_result,
    input   Word            next_address,
    input   ReadOp          validated_read_op,
    input   Word            data_mem_read_data,
    input   Word            lcd_read_data,
    input   Word            button_read_data,
    input   Word            direct_button_read_data,
    input   Word            vga_read_data,
    input   DeviceDataSrc   device_data_src,
    input   rdSrc           rd_src,
    input   RegAddr         rd_addr,
    input   rdWrite         rd_write,

    output  PCSrc           pc_src_register,
    output  Word            alu_result_register,
    output  Word            next_address_register,
    output  ReadOp          validated_read_op_register,
    output  Word            data_mem_read_data_register,
    output  Word            lcd_read_data_register,
    output  Word            button_read_data_register,
    output  Word            direct_button_read_data_register,
    output  Word            vga_read_data_register,
    output  DeviceDataSrc   device_data_src_register,
    output  rdSrc           rd_src_register,
    output  RegAddr         rd_addr_register,
    output  rdWrite         rd_write_register
);
    assign data_mem_read_data_register      = data_mem_read_data;
    assign lcd_read_data_register           = lcd_read_data;
    assign button_read_data_register        = button_read_data;
    assign direct_button_read_data_register = direct_button_read_data;
    assign vga_read_data_register           = vga_read_data;
    initial begin
        pc_src_register             = PCSRC_NULL;
        alu_result_register         = '0;
        next_address_register       = '0;
        validated_read_op_register  = NO_READ_OP;
        device_data_src_register    = DEVICE_DATA_SRC_NONE;
        rd_src_register             = RDSRC_ALU_RESULT;
        rd_addr_register            = RegAddr'('0);
        rd_write_register           = NO_RD_WRITE;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pc_src_register             <= PCSRC_NEXT_ADDRESS;
            alu_result_register         <= '0;
            next_address_register       <= '0;
            validated_read_op_register  <= NO_READ_OP;
            device_data_src_register    <= DEVICE_DATA_SRC_NONE;
            rd_src_register             <= RDSRC_ALU_RESULT;
            rd_addr_register            <= RegAddr'('0);
            rd_write_register           <= NO_RD_WRITE;
        end else begin
            pc_src_register             <= pc_src;
            alu_result_register         <= alu_result;
            next_address_register       <= next_address;
            validated_read_op_register  <= validated_read_op;
            device_data_src_register    <= device_data_src;
            rd_src_register             <= rd_src;
            rd_addr_register            <= rd_addr;
            rd_write_register           <= rd_write;
        end
    end
endmodule