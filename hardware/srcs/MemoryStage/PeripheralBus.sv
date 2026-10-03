`timescale 1ns/1ps

// Only for device/peripheral that have to interact with the outside world.

interface LCDDeviceBus;
    logic [7:0] write_data;
    logic       rs;
    logic       e;

    modport master (
        output write_data, rs, e
    );
    modport slave (
        input write_data, rs, e
    );
endinterface

interface ButtonDeviceBus #(
    parameter BUTTON_ROWS = 5,
    parameter BUTTON_COLS = 4
);
    logic col_in    [BUTTON_COLS-1:0];
    logic row_out   [BUTTON_ROWS-1:0];

    modport master (
        input col_in,
        output row_out
    );
    modport slave (
        input row_out,
        output col_in
    );
endinterface