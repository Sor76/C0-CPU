`timescale 1ns/1ps

// The name is a bit weird here.
// The bus include both logic for interstage and intrastage communication.
// The master of each bus is located in the stage with the same name as the bus, and the slave is where ever the signal goes to.
// The master module should recieve clk and rst_n signal from the interface where it have a role of master.
// There is no Writeback Stage Bus because it is just output of Memory Stage Bus.

interface FetchStageBus (
    input logic clk,
    input logic rst_n
);
    logic [31:0] instruction,
    logic [31:0] address

    modport master (
        input clk, rst_n
        output instruction
        ref address
    );
    modport slave (
        input instruction, address
    );
endinterface

interface DecodeStageBus
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic clk,
    input logic rst_n
);
    logic [31:0]  extended_imm;
    logic [31:0]  rs2_data;
    logic [31:0]  current_address;
    logic [31:0]  rs1_data;
    logic [1:0]   alu_operand;
    ALUOp         alu_op;
    JmpOp         jmp_op;
    MEMRead       mem_read;
    MEMWrite      mem_write;
    rdSrc         rd_src;
    logic [4:0]   rd_address;
    rdWrite       rd_write;

    modport master (
        input clk, rst_n
        output extended_imm, rs2_data, current_address, rs1_data, alu_operand, alu_op, jmp_op, mem_read, mem_write, rd_src, rd_address, rd_write
    );
    modport slave (
        input extended_imm, rs2_data, current_address, rs1_data, alu_operand, alu_op, jmp_op, mem_read, mem_write, rd_src, rd_address, rd_write
    );
endinterface

interface ExecuteStageBus
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic clk,
    input logic rst_n
);
    PCSrc         pc_src;
    logic [31:0]  alu_result;
    logic [31:0]  next_address;
    logic [31:0]  rs2_data;
    MEMRead       mem_read;
    MEMWrite      mem_write;
    rdSrc         rd_src;
    logic [4:0]   rd_address;
    rdWrite       rd_write;

    modport master (
        input clk, rst_n
        output pc_src, alu_result, next_address, rs2_data, mem_read, mem_write, rd_src, rd_address, rd_write
    );
    modport slave (
        input pc_src, alu_result, next_address, rs2_data, mem_read, mem_write, rd_src, rd_address, rd_write
    );
endinterface

interface MemoryStageBus (
    input logic clk,
    input logic rst_n
);
    PCSrc         pc_src;
    logic [31:0]  alu_result;
    logic [31:0]  next_address;
    logic [31:0]  device_read_data;
    rdSrc         rd_src;
    logic [4:0]   rd_address;
    rdWrite       rd_write;

    modport master (
        input clk, rst_n
        output pc_src, alu_result, next_address, next_address, device_read_data, rd_src, rd_address, rd_write
    );
    modport slave (
        input pc_src, alu_result, next_address, next_address, device_read_data, rd_src, rd_address, rd_write
    );
endinterface