`timescale 1ns/1ps

module Top #(
    localparam int      INSTRUCTION_MEM_ADDRESS_WIDTH   = 16,
    localparam string   PROGRAM_NAME                    = "test.mem",
    localparam int      DATA_MEM_ADDRESS_WIDTH          = 16,

    localparam int      BUTTON_ROWS                 = 5,
    localparam int      BUTTON_COLS                 = 4
) (
    input logic clk,
    input logic rst_n, // Reset button

    // LCD connection
    output logic lcd_write_data,
    output logic lcd_rs,
    output logic lcd_e,

    // Buttons connection (Exclude reset button)
    input logic button_col_in [BUTTON_COLS-1:0],
    output logic button_row_out [BUTTON_ROWS-1:0]
);
    // Fetch Stage
    FetchStageBus if_stage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    PC pc (
        .if_stage_bus(if_stage_bus.master),
        .wb_stage_bus(wb_stage_bus.slave)
    );
    InstructionMemoryController #(
        .ADDRESS_WIDTH(INSTRUCTION_MEM_ADDRESS_WIDTH),
        .PROGRAM_NAME(PROGRAM_NAME)
    ) instruction_memory_controller (
        .if_stage_bus(if_stage_bus.master)
    );

    // Decode Stage
    DecodeStageBus id_stage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    ControlUnit cu (
        .id_stage_bus(id_stage_bus.master),
        .if_stage_bus(if_stage_bus.slave)
    );
    ImmediateAssembler immediate_assembler (
        .id_stage_bus(id_stage_bus.master)
    );
    RegisterFile register_file (
        .id_stage_bus(id_stage_bus.master),
        .wb_stage_bus(wb_stage_bus.slave)
    );

    // Execute Stage
    ExecuteStageBus ex_stage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    ExecutionUnit eu (
        .ex_stage_bus(ex_stage_bus.master),
        .id_stage_bus(id_stage_bus.slave)
    );

    // Memory Stage
    MemoryStageBus mem_stage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    LCDDeviceBus lcd_bus ();
    ButtonDeviceBus #(
        .BUTTON_ROWS(BUTTON_ROWS),
        .BUTTON_COLS(BUTTON_COLS)
    ) button_bus ();
    SystemBus #(
        .DATA_MEM_ADDRESS_WIDTH(DATA_MEM_ADDRESS_WIDTH),
        .BUTTON_ROWS(BUTTON_ROWS),
        .BUTTON_COLS(BUTTON_COLS)
    ) system_bus (
        .mem_stage_bus(mem_stage_bus.master),
        .device_bus(mem_stage_bus.device),
        .ex_stage_bus(ex_stage_bus.slave),

        .lcd_bus(lcd_bus.master),
        .button_bus(button_bus.master)
    );
    assign lcd_write_data       = lcd_bus.write_data;
    assign lcd_rs               = lcd_bus.rs;
    assign lcd_e                = lcd_bus.e;
    assign button_bus.col_in    = button_col_in;
    assign button_row_out       = button_bus.row_out;

    // Writeback Stage
    WritebackStageBus wb_stage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    DeviceDataMux device_data_mux (
        .wb_stage_bus(wb_stage_bus.master),
        .mem_stage_bus(mem_stage_bus.slave)
    );
    BitExtender bit_extender (
        .wb_stage_bus(wb_stage_bus),
        .mem_stage_bus(mem_stage_bus.slave)
    );
    RegisterFileMux register_file_mux (
        .wb_stage_bus(wb_stage_bus.master),
        .mem_stage_bus(mem_stage_bus.slave)
    );
endmodule