`timescale 1ns/1ps

module ProgramCounter
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic   clk,
    input   logic   rst_n,

    input   PCSrc   pc_src,
    input   Word    alu_result,

    output  Word    address,
    output  Word    selected_address
);
    // Address selcting
    always_comb begin
        case (pc_src)
            PCSRC_NEXT_ADDRESS:         selected_address = address + 4;
            PCSRC_JUMP_ADDRESS:         selected_address = alu_result;
            PCSRC_JUMP_JALR_ADDRESS:    selected_address = alu_result[31:1] << 1'b1;
            default:                    selected_address = '0;
        endcase
    end

    // Updating address register
    initial address = '0;
    always_ff @(posedge clk) begin
        address <= (!rst_n) ? '0 : selected_address;
    end
endmodule