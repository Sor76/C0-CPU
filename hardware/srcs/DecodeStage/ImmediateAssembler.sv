`timescale 1ns/1ps

module ImmediateAssembler
    // Bro, why does the SystemVerilog have to use wild card import for importing only one enum type and its value.
    import OtherSignals_pkg::*;
    import Types_pkg::*;
(
    input   logic [19:0]    raw_imm,
    input   InstFormat      inst_format,
    output  Word            extended_imm
);
    always_comb begin
        case (inst_format)
            I_TYPE, S_TYPE: extended_imm = $signed(raw_imm[11:0]);
            B_TYPE:         extended_imm = $signed({raw_imm[11:0], 1'b0});
            U_TYPE:         extended_imm = $signed({raw_imm, 12'b0});
            J_TYPE:         extended_imm = $signed({raw_imm, 1'b0});
            default:        extended_imm = '0;
        endcase
    end
    
endmodule