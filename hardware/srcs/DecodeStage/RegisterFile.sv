`timescale 1ns/1ps

module RegisterFile
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic   clk,
    input   logic   rst_n,

    input   RegAddr rs1_addr,
    input   RegAddr rs2_addr,

    input   RegAddr rd_addr,
    input   rdWrite rd_write,
    input   Word    rd_write_data,
    
    output  Word    rs1_data,
    output  Word    rs2_data
);
    logic [31:0] register_array [31:0] = '{default: 0};

    initial begin
        rs1_data = '0;
        rs2_data = '0;
    end

    // Helper functions
    function bit rd_write_check;
        return rd_write == RD_WRITE && rd_addr != RegAddr'('0);
    endfunction
    function bit address_collide (input logic [31:0] read_addr);
        return rd_write_check() && rd_addr == read_addr;
    endfunction

    // rd writing logic / reset
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            register_array <= '{default: 0};
        end else if (rd_write_check()) begin
            register_array[rd_addr] <= rd_write_data;
        end
    end

    // rs reading logic
    always_ff @(posedge clk) begin
        rs1_data <= address_collide(rs1_addr) ? rd_write_data : register_array[rs1_addr];
        rs2_data <= address_collide(rs2_addr) ? rd_write_data : register_array[rs2_addr];
    end
endmodule