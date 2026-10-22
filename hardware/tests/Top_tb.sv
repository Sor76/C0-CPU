`timescale 1ns/1ps

module Top_tb;
    logic clk;
    logic rst_n;

    logic [7:0] lcd_write_data;
    logic lcd_rs;
    logic lcd_e;

    logic button_col_in [0:3];
    logic button_row_out [0:4];

    Top dut (
        .clk(clk),
        .rst_n(rst_n),

        .lcd_write_data(lcd_write_data),
        .lcd_rs(lcd_rs),
        .lcd_e(lcd_e),
        
        .button_col_in(button_col_in),
        .button_row_out(button_row_out)
    );

    function static int find_zero(input logic array [0:4]);
        int idx[$] = array.find_index() with (item == 0);
        return (idx.size() == 0) ? -1 : idx[0];
    endfunction
    logic button_pressing_matrix [0:4][0:3] = '{
        '{1, 1, 1, 1},
        '{1, 1, 1, 1},
        '{1, 1, 1, 1},
        '{1, 1, 1, 1},
        '{1, 1, 1, 1}
    };
    int idx;
    logic [3:0] col_packed;
    logic [4:0] row_packed;
    always_comb begin
        idx = find_zero(button_row_out);        
        button_col_in = button_pressing_matrix[idx];        
        col_packed = {>>{button_col_in}};
        row_packed = {>>{button_row_out}};
        $display("out: %b, in: %b, idx: %d, test: %p", row_packed, col_packed, idx, button_pressing_matrix[0]);
    end

    initial begin
        clk = 0;
        rst_n = 1;
        button_col_in = '{default: 0};
        forever #10ns clk = !clk;
    end

    // int row;
    // int col;
    // initial begin
    //     forever #75ms begin
    //         button_pressing_matrix = '{default: 1};

    //         assert (std::randomize(row) with {row inside {[0:4]};} && std::randomize(row) with {row inside {[0:3]};})
    //         else   $fatal(1, "Unable to randomize row/col value.");

    //         button_pressing_matrix[row][col] = 0;
    //     end
    // end
    initial begin
        #75ms
        button_pressing_matrix[2][1] = 0;
        #75ms
        button_pressing_matrix = '{default: 1};
    end
endmodule