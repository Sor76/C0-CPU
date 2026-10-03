`timescale 1ns/1ps

module ImmediateAssembler
    // Bro, why does the SystemVerilog have to use wild card import for importing only one enum type and its value.
    import OtherSignals_pkg::*;
(
    DecodeStageBus.master id_stage_bus
);
    always_comb begin
        case (id_stage_bus.instruction_format)
            I_TYPE, S_TYPE: id_stage_bus.extended_imm = $signed(id_stage_bus.raw_imm[11:0]);
            B_TYPE:         id_stage_bus.extended_imm = $signed({id_stage_bus.raw_imm[11:0], 1'b0});
            U_TYPE:         id_stage_bus.extended_imm = $signed({id_stage_bus.raw_imm, 12'b0});
            J_TYPE:         id_stage_bus.extended_imm = $signed({id_stage_bus.raw_imm, 1'b0});
            default:        id_stage_bus.extended_imm = '0;
        endcase
    end
    
endmodule