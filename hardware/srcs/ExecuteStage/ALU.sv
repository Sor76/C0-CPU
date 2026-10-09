`timescale 1ns/1ps

module ALU
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   ALUOp   alu_op,
    input   Word    operand_1,
    input   Word    operand_2,
    output  Word    alu_result
);
    always_comb begin
        case (alu_op)
            ADD:        alu_result = operand_1 + operand_2;
            SUB:        alu_result = operand_1 - operand_2;
            SLL:        alu_result = operand_1 << operand_2;
            SLT:        alu_result = $signed(operand_1) < $signed(operand_2);
            SLTU:       alu_result = $unsigned(operand_1) < $unsigned(operand_2);
            XOR:        alu_result = operand_1 ^ operand_2;
            SRL:        alu_result = operand_1 >> operand_2;
            SRA:        alu_result = operand_1 >>> operand_2;
            OR:         alu_result = operand_1 | operand_2;
            AND:        alu_result = operand_1 & operand_2;
            default:    alu_result = '0;
        endcase
    end
endmodule