`timescale 1ns/1ps

// For any connecting that goes out of one module and in to another.
// The name is a bit weird here.
// The bus include both logic for interstage and intrastage communication.
// The master modport is for the unit located inside this stage
// , while the slave is the stage that will take data from the master stage.
// The master module should recieve clk and rst_n signal from the interface where it have a role of master.

interface FetchStageBus (
    input logic clk,
    input logic rst_n
);
    // Interstage
    logic [31:0]    instruction;
    logic [31:0]    address; // The address that the PC have jumped into.

    // Intrastage
    logic [31:0]    selected_address; // The address that the PC will jump into in the next clock cycle.
    
    modport master (
        input clk, rst_n,
        output instruction,
        ref selected_address, address
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
    // Interstage
    logic [31:0]    extended_imm;
    logic [31:0]    rs2_data;
    logic [31:0]    current_address;
    logic [31:0]    rs1_data;
    logic [1:0]     alu_operand;
    ALUOp           alu_op;
    ComOp           com_op;
    JmpOp           jmp_op;
    ReadOp          read_op;
    WriteOp         write_op;
    rdSrc           rd_src;
    logic [4:0]     rd_address;
    rdWrite         rd_write;

    // Intrastage
    logic signed [19:0] raw_imm;
    InstructionFormat   instruction_format;
    logic [4:0]         rs1_address;
    logic [4:0]         rs2_address;
    logic [6:0]         opcode;
    logic [2:0]         funct3;
    logic [6:0]         funct7;

    modport master (
        input clk, rst_n,
        output extended_imm, rs2_data, current_address, rs1_data, alu_operand, alu_op, com_op, jmp_op, read_op, write_op, rd_src, rd_address, rd_write,
        ref raw_imm, instruction_format, rs1_address, rs2_address, opcode, funct3, funct7
    );
    modport slave (
        input extended_imm, rs2_data, current_address, rs1_data, alu_operand, alu_op, com_op, jmp_op, read_op, write_op, rd_src, rd_address, rd_write
    );
endinterface

interface ExecuteStageBus
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic clk,
    input logic rst_n
);
    // Interstage
    PCSrc           pc_src;
    logic [31:0]    alu_result;
    logic [31:0]    next_address;
    logic [31:0]    rs2_data;
    ReadOp          read_op;
    WriteOp         write_op;
    rdSrc           rd_src;
    logic [4:0]     rd_address;
    rdWrite         rd_write;

    // Intrastage
    logic [31:0]    operand_1;
    logic [31:0]    operand_2;

    modport master (
        input clk, rst_n,
        output pc_src, alu_result, next_address, rs2_data, read_op, write_op, rd_src, rd_address, rd_write,
        ref operand_1, operand_2
    );
    modport slave (
        input pc_src, alu_result, next_address, rs2_data, read_op, write_op, rd_src, rd_address, rd_write
    );
endinterface

interface MemoryStageBus
    import ControlSignals_pkg::*;
# (
    parameter int DEVICE_COUNTS = 3 // Data Memory + LCD Controller + Button Controller
) (
    input logic clk,
    input logic rst_n
);
    // Interstage
    PCSrc                               pc_src;
    logic [31:0]                        alu_result;
    logic [31:0]                        next_address;
    ReadOp                              read_op;

    logic [31:0]                        data_mem_read_data;
    logic [31:0]                        lcd_read_data;
    logic [31:0]                        button_read_data;
    DeviceDataSrc                       device_data_src;

    rdSrc                               rd_src;
    logic [4:0]                         rd_address;
    rdWrite                             rd_write;

    // Intrastage
    logic                               device_select [DEVICE_COUNTS:0]; // DEVICE_COUNTS + 1 for not selecting any of the device.
    logic [31-$clog2(DEVICE_COUNTS):0]  address;
    logic [31:0]                        write_data;
    WriteOp                             write_op;

    modport master (
        input clk, rst_n,
        
        // Stage to Stage
        output pc_src, alu_result, next_address, device_data_src, rd_src, rd_address, rd_write,
    
        // Processor to Device
        output device_select, address, write_data, write_op,

        // Both
        output read_op
    );
    modport slave (
        // From MEM stage
        input pc_src, alu_result, next_address, read_op, device_data_src, rd_src, rd_address, rd_write, 

        // From MEM stage's devices
        input data_mem_read_data, lcd_read_data, button_read_data
    );
    modport device (
        // Processor to Device
        input clk, rst_n, device_select, address, write_data, read_op, write_op,

        // Device to Processor
        output data_mem_read_data, lcd_read_data, button_read_data
    );
endinterface

interface WritebackStageBus
    import ControlSignals_pkg::*;
(
    input logic clk,
    input logic rst_n
);
    PCSrc           pc_src;
    logic [31:0]    alu_result;
    logic [31:0]    device_data; // Selected, but not extended yet
    logic [31:0]    device_extended_data; // Selected and extended
    logic [31:0]    rd_write_data;
    logic [4:0]     rd_address;
    rdWrite         rd_write;

    modport master (
        output pc_src, alu_result, rd_write_data, rd_address, rd_write,
        ref device_data, device_extended_data
    );
    modport slave (
        input pc_src, alu_result, rd_write_data, rd_address, rd_write
    );
endinterface