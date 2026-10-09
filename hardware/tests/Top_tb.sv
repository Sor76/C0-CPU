`timescale 1ns/1ps

module Top_tb;
    logic clk;
    logic rst_n;

    logic [7:0] lcd_write_data;
    logic lcd_rs;
    logic lcd_e;

    logic button_col_in [3:0];
    logic button_row_out [4:0];

    Top dut (
        .clk(clk),
        .rst_n(rst_n),

        .lcd_write_data(lcd_write_data),
        .lcd_rs(lcd_rs),
        .lcd_e(lcd_e),
        
        .button_col_in(button_col_in),
        .button_row_out(button_row_out)
    );

    initial begin
        clk = 0;
        rst_n = 1;

        button_col_in = '{default: 0};

        forever #10ns clk = !clk;
    end
    initial begin
        repeat (2**16+100) begin
            @(negedge clk);
        end
        $finish;
    end
endmodule