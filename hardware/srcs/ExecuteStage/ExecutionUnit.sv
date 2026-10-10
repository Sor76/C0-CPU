`timescale 1ns/1ps

module ExecutionUnit
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
    import Types_pkg::*;
(
    input   Word        extended_imm,
    input   Word        rs2_data,
    input   Word        address,
    input   Word        rs1_data,

    input   logic [1:0] alu_operand,
    input   ALUOp       alu_op,
    input   ComOp       com_op,
    input   JmpOp       jmp_op,

    output  PCSrc       pc_src,
    output  Word        alu_result,
    output  Word        next_address
);
    Word operand_1;
    Word operand_2;

    assign next_address = address + 4;
    ALU alu (
        .alu_op(alu_op),
        .operand_1(operand_1),
        .operand_2(operand_2),
        .alu_result(alu_result)
    );
    JmpHandler jmp_handler (
        .com_op(com_op),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .jmp_op(jmp_op),
        .pc_src(pc_src)
    );

    // Operand mux
    always_comb begin
        case (alu_operand[0])
            1'b0: operand_1 = rs1_data;
            1'b1: operand_1 = address;
        endcase
        case (alu_operand[1])
            1'b0: operand_2 = rs2_data;
            1'b1: operand_2 = extended_imm;
        endcase
    end
endmodule