`timescale 1ns/1ps

module ButtonController
    import ControlSignals_pkg::*;
    import Types_pkg::*;
#(
    parameter int BUTTON_ROWS           = 5, // Total rows of the matrix.
    parameter int BUTTON_COLS           = 4, // Total columns of the matrix.
    parameter int TARGET_MS             = 50, // set amount of ms for the value to be the same value before counting as finished bouncing
    parameter int CLOCK_RATE            = 50_000_000,

    localparam int SYNC_STAGES          = 2
) (
    input   logic   clk,
    input   logic   rst_n,

    input   logic   device_select,

    output  Word    data_out,

    input   logic   col_in [0:BUTTON_COLS-1],
    output  logic   row_out [0:BUTTON_ROWS-1]
);
    // ButtonController controls the scanning and debounce process of the button matrix, and write the lower right most button into data_out port.
    // The data_out port could have an output of 0 meaning that no button have been pressed, or it currently still under debounce process.
    // But, if the button have been pressed, the ButtonController will send out the ID of the lower right most button to the data_out port.
    // The ID is calculator by row of the button * BUTTON_COLS + column of the button + 1.
    // 
    // Default matrix layout
    // col 0  1  2  3
    // row
    // 0   x  x  x  x
    // 1   x  x  x  x
    // 2   x  x  x  x
    // 3   x  x  x  x
    // 4   x  x  x  x
    // 'x' is the button. The CPU could interpret these buttons as any key. It's up to the program to decided which key would that be.
    // Row and column count could be anything more than one, but on the expansion board I made it would be 5x4.
    // This module is for pul-up configuration.
    // 
    // Calculator layout
    // col 0  1  2  3
    // row
    // 0   (  ) <-  c
    // 1   7  8  9  x
    // 2   4  5  6  -
    // 3   1  2  3  +
    // 4  00  0  .  =
    //
    // There is one additional button that isn't handle by the Button Controller, which is the reset button.
    // The reset button will be hardware debounce using capacitor, and directly connected to the reset pin of the processor.
    // 
    // How it works
    // 1. The Button Controller use row scanning, which means row ports are the outputs, while column ports are the inputs.
    // 2. In each clock cycle, the Button Controller select one specific row to have an output of 0, while the other are 1, before
    //    moving on to the next row.
    // 3. When a button or more is pressed, the corresponding column port(s) will receive zero, while the other will receive 1.
    //    The value of the column ports are then put into a set stage of synchronizer (just one or more flip-flops) to prevent meta-stability.
    //    2 stages of synchronizer should be more than enough.
    // 4. The values in the last stage of the synchronizer is then put into matrix of raw input from the buttons.
    //    When updating a row's value, the index of the row (which use row index that is shared with the row scanning part) must be
    //    subtract by the amount of the synchronization stages to compensate the delay between reading from the column ports and the
    //    matrix updating.
    // 5. The raw input matrix is then used just like a normal button value in debouncing, which is if the button's reading is the same
    //    value for set amount of time (usually 50ms) that means the button is finished bouncing.
    // 6. In case of multiple buttons being pressed at the same time. Button Controller will prioritize the lower-right button first.



    // Row scanning
    initial begin
        row_out = '{default: 1};
        row_out[0] = 1'b0;
    end
    function logic [$clog2(BUTTON_ROWS)-1:0] row_index_rounding(input logic [$clog2(BUTTON_ROWS)-1:0] row_idx);
        // Rolling back the index if it is out of range.
        return (row_idx >= BUTTON_ROWS) ? row_idx - BUTTON_ROWS : row_idx;
    endfunction
    logic [$clog2(BUTTON_ROWS)-1:0] current_row = '0;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            current_row <= 0;
            row_out <= '{default: 1};
            row_out[0] <= 1'b0;
        end else begin
            if (current_row == BUTTON_ROWS-1) current_row <= 0;
            else current_row <= current_row + 1;

            row_out <= '{default: 1};
            row_out[row_index_rounding(current_row + 1)] <= 1'b0;
        end
    end


    // Column synchronization
    logic cols_sync_array [0:SYNC_STAGES-1][0:BUTTON_COLS-1] = '{default: 1};
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cols_sync_array <= '{default: 1};
        end else begin
            // Get new input
            cols_sync_array[0] <= col_in;

            // Stage shifting
            for (int stage = 0; stage < SYNC_STAGES - 1; stage = stage + 1) begin
                cols_sync_array[stage+1] <= cols_sync_array[stage];
            end
        end
    end


    // Raw input matrix
    function logic [$clog2(BUTTON_ROWS)-1:0] calculate_row(input logic signed [$clog2(BUTTON_ROWS)-1:0] row_idx);
        // Python's negative indexing.
        // Useful for compenstating the delay of sync stages.
        return (row_idx < 0) ? BUTTON_ROWS + row_idx : row_idx;
    endfunction
    logic [$clog2(BUTTON_ROWS)-1:0] after_sync_row_idx;
    logic raw_input_matrix [0:BUTTON_ROWS-1][0:BUTTON_COLS-1] = '{default: 0}; // Already inverted
    assign after_sync_row_idx = calculate_row($signed(current_row - SYNC_STAGES));
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            raw_input_matrix <= '{default: 0};
        end else begin
            raw_input_matrix[after_sync_row_idx] <= {<<{~BUTTON_COLS'({<<{cols_sync_array[SYNC_STAGES-1]}})}};
        end
    end


    // Dividing the clock down to 1000Hz (1ms per cycle)
    localparam CLOCK_PER_MS = CLOCK_RATE / 1000;
    logic [$clog2(CLOCK_PER_MS)-1:0] clk_counter = 1; // Preventing the first clock cycle to look like the first ms is reached.
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            clk_counter <= 0;
        end else begin
            if (clk_counter >= CLOCK_PER_MS) clk_counter <= 0;
            else clk_counter <= clk_counter + 1;
        end
    end


    // Debouncing each button
    // holy nesting
    logic [$clog2(TARGET_MS)-1:0] ms_timer_matrix [0:BUTTON_ROWS-1][0:BUTTON_COLS-1] = '{default: 0};
    logic previous_input_matrix [0:BUTTON_ROWS-1][0:BUTTON_COLS-1] = '{default: 0};
    logic debounced_input_matrix [0:BUTTON_ROWS-1][0:BUTTON_COLS-1] = '{default: 0};
    always_ff  @(posedge clk) begin
        if (!rst_n) begin
            ms_timer_matrix <= '{default: 0};
            previous_input_matrix <= '{default: 0};
            debounced_input_matrix <= '{default: 0};
        end else begin
            for (int row = 0; row < BUTTON_ROWS; row = row + 1) begin
                for (int col = 0; col < BUTTON_COLS; col = col + 1) begin
                    if (raw_input_matrix[row][col] == previous_input_matrix[row][col]) begin
                        if (clk_counter == 0) begin    
                            if (ms_timer_matrix[row][col] >= TARGET_MS) begin
                                debounced_input_matrix[row][col] <= raw_input_matrix[row][col]; // Debounce completed.
                                ms_timer_matrix[row][col] <= 0;
                            end else begin
                                ms_timer_matrix[row][col] <= ms_timer_matrix[row][col] + 1; // Time isn't reached yet, continue counting.
                            end
                        end
                    end else begin
                        ms_timer_matrix[row][col] <= 0; // Reading of the button changed, reset the timer.
                    end

                end
            end

            previous_input_matrix <= raw_input_matrix;
        end
    end

    // Read operation
    initial data_out = 0;
    always @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
        end else if (device_select) begin
            for (int row = 0; row < BUTTON_ROWS; row = row + 1) begin
                for (int col = 0; col < BUTTON_COLS; col = col + 1) begin
                    if (debounced_input_matrix[row][col]) data_out <= row * BUTTON_COLS + col + 1;
                end
            end
        end
    end
endmodule