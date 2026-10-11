`timescale 1ns/1ps

module SystemBus
    import ControlSignals_pkg::*;
    import Types_pkg::*;
#(
    parameter   int DATA_MEM_ADDRESS_WIDTH      = 16,
    parameter   int BUTTON_ROWS                 = 5,
    parameter   int BUTTON_COLS                 = 4,

    localparam  int DEVICE_COUNTS               = 3,
    localparam  int DATA_MEM_DEVICE_SELECT_NUM  = 0,
    localparam  int LCD_DEVICE_SELECT_NUM       = 1,
    localparam  int BUTTON_DEVICE_SELECT_NUMBER = 2
) (
    input   logic           clk,
    input   logic           rst_n,

    input   Word            alu_result,
    input   Word            rs2_data,
    input   ReadOp          read_op,
    input   WriteOp         write_op,

    output  Word            data_mem_read_data,
    output  Word            lcd_read_data,
    output  Word            button_read_data,

    output  ReadOp          validated_read_op,
    output  DeviceDataSrc   device_data_src,

    output  logic [7:0]     lcd_write_data,
    output  logic           lcd_rs,
    output  logic           lcd_e,

    input   logic           col_in [0:BUTTON_COLS-1],
    output  logic           row_out [0:BUTTON_ROWS-1]
);

    logic                               device_select [DEVICE_COUNTS-1:0];
    logic [31-$clog2(DEVICE_COUNTS):0]  device_address;
    WriteOp                             validated_write_op;

    AddressDecoder address_decoder (
        .alu_result(alu_result),
        .read_op(read_op),
        .write_op(write_op),

        .device_select(device_select),
        .device_address(device_address),
        .validated_read_op(validated_read_op),
        .validated_write_op(validated_write_op),

        .device_data_src(device_data_src)
    );

    // Devices
    DataMemoryController #(
        .ADDRESS_WIDTH(DATA_MEM_ADDRESS_WIDTH)
    ) data_memory_controller (
        .clk(clk),
        .rst_n(rst_n),

        .device_select(device_select[DATA_MEM_DEVICE_SELECT_NUM]),
        .device_address(device_address[31-DATA_MEM_ADDRESS_WIDTH:0]),
        .write_data(rs2_data),
        .validated_read_op(validated_read_op),
        .validated_write_op(validated_write_op),

        .data_out(data_mem_read_data)
    );
    LCDController lcd_controller (
        .clk(clk),
        .rst_n(rst_n),

        .device_select(device_select[LCD_DEVICE_SELECT_NUM]),
        .write_data(rs2_data),
        .validated_write_op(validated_write_op),

        .data_out(lcd_read_data),

        .lcd_write_data(lcd_write_data),
        .lcd_rs(lcd_rs),
        .lcd_e(lcd_e)
    );
    ButtonController #(
        .BUTTON_ROWS(BUTTON_ROWS),
        .BUTTON_COLS(BUTTON_COLS)
    ) button_controller (
        .clk(clk),
        .rst_n(rst_n),

        .device_select(device_select[BUTTON_DEVICE_SELECT_NUMBER]),
        .validated_read_op(validated_read_op),

        .data_out(button_read_data),

        .col_in(col_in),
        .row_out(row_out)
    );
endmodule