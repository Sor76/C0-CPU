`timescale 1ns/1ps

module Top_tb;
    logic clk;

    logic [4:0] direct_button_in = '1;

    logic [8:0] vga_x;
    logic [7:0] vga_y;
    logic [4:0] vga_rgb;
    logic       vga_parity;
    logic       vga_strobe;

    Top dut (
        .clk(clk),

        .direct_button_in(direct_button_in),

        .vga_x(vga_x),
        .vga_y(vga_y),
        .vga_rgb(vga_rgb),
        .vga_parity(vga_parity),
        .vga_strobe(vga_strobe)
    );

    initial begin
        clk = 0;
        // rst_n = 1;
        // button_col_in = '{default: 0};
        forever #10ns clk = !clk;
    end

    initial begin
        #25ms
        direct_button_in = '1;
        direct_button_in[0] = 0;
        #25ms
        direct_button_in = '1;
        direct_button_in[1] = 0;
        #25ms
        direct_button_in = '1;
        direct_button_in[2] = 0;
        #25ms
        direct_button_in = '1;
        direct_button_in[3] = 0;
        #25ms
        direct_button_in = '1;
        direct_button_in[4] = 0;

        #25ms
        direct_button_in = '0;
    end
endmodule