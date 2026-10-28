`timescale 1ns/1ps

module VGAController
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic        clk,
    input   logic        rst_n,

    input   logic        device_select,
    input   Word         write_data,
    input   WriteOp      validated_write_op,

    output  Word         data_out,

    output  logic [8:0] vga_x,
    output  logic [7:0] vga_y,
    output  logic [4:0] vga_rgb,
    output  logic       vga_parity,
    output  logic       vga_strobe
);
    // Read operation
    assign data_out = '0;

    // Write operation / Reset
    initial begin
        vga_x       = '0;
        vga_y       = '0;
        vga_rgb     = '0;
        vga_parity  = 0;
        vga_strobe  = 0;
    end
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            vga_x       <= '0;
            vga_y       <= '0;
            vga_rgb     <= '0;
            vga_parity  <= 0;
            vga_strobe  <= 0;
        end else if (device_select && validated_write_op != NO_WRITE_OP) begin 
            case (validated_write_op)
                WRITE_OP_4_BYTES: begin
                    vga_x       <= write_data[8:0];
                    vga_y       <= write_data[16:9];
                    vga_rgb     <= write_data[21:17];
                    vga_parity  <= write_data[22];
                    vga_strobe  <= write_data[23];
                end
                default: begin
                    vga_x       <= '0;
                    vga_y       <= '0;
                    vga_rgb     <= '0;
                    vga_parity  <= 0;
                    vga_strobe  <= 0;
                end
            endcase
        end
    end
endmodule