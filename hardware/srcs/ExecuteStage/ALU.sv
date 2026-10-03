`timescale 1ns/1ps

module ALU
    import ControlSignals_pkg::*;
(
    ExecuteStageBus.master ex_stage_bus,
    DecodeStageBus.slave id_stage_bus
);
    always_comb begin
        case (id_stage_bus.alu_op)
            ADD: ex_stage_bus.alu_result = ex_stage_bus.operand_1 + ex_stage_bus.operand_2;
            SUB: ex_stage_bus.alu_result = ex_stage_bus.operand_1 - ex_stage_bus.operand_2;
            SLL: ex_stage_bus.alu_result = ex_stage_bus.operand_1 << ex_stage_bus.operand_2;
            SLT: ex_stage_bus.alu_result = $signed(ex_stage_bus.operand_1) < $signed(ex_stage_bus.operand_2);
            SLTU: ex_stage_bus.alu_result = $unsigned(ex_stage_bus.operand_1) < $unsigned(ex_stage_bus.operand_2);
            XOR: ex_stage_bus.alu_result = ex_stage_bus.operand_1 ^ ex_stage_bus.operand_2;
            SRL: ex_stage_bus.alu_result = ex_stage_bus.operand_1 >> ex_stage_bus.operand_2;
            SRA: ex_stage_bus.alu_result = ex_stage_bus.operand_1 >>> ex_stage_bus.operand_2;
            OR: ex_stage_bus.alu_result = ex_stage_bus.operand_1 | ex_stage_bus.operand_2;
            AND: ex_stage_bus.alu_result = ex_stage_bus.operand_1 & ex_stage_bus.operand_2;
            default: ex_stage_bus.alu_result = '0;
        endcase
    end
endmodule