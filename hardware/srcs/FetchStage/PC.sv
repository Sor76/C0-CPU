`timescale 1ns/1ps

module PC
    import ControlSignals_pkg::*;
(
    input logic         clk,
    input logic         rst_n,
    
    input PCSrc         pc_src,
    input logic [31:0]  jump_address,

    output logic [31:0] address = 0
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            address <= 0;
        end else begin
            case (pc_src)
                PCSRC_NEXT_ADDRESS: address <= address + 4;
                PCSRC_JUMP_ADDRESS: address <= jump_address;
                PCSRC_JUMP_JALR_ADDRESS: address <= {jump_address[31:1], 1'b0};
            endcase
        end
    end
endmodule