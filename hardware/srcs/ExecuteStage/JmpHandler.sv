`timescale 1ns/1ps

module JmpHandler
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::JmpOp;
(
    ExecuteStageBus.master ex_stage_bus,
    DecodeStageBus.slave id_stage_bus
);
    logic comparison_result;
    logic [2:0] sum_result;
    assign sum_result = id_stage_bus.jmp_op + comparison_result;
    assign ex_stage_bus.pc_src = PCSrc'(sum_result[2:1]);

    // Comparator
    always_comb begin
        case (id_stage_bus.com_op)
            EQ:         comparison_result = id_stage_bus.rs1_data == id_stage_bus.rs2_data;
            NE:         comparison_result = id_stage_bus.rs1_data != id_stage_bus.rs2_data;
            LT:         comparison_result = $signed(id_stage_bus.rs1_data) < $signed(id_stage_bus.rs2_data);
            GE:         comparison_result = $signed(id_stage_bus.rs1_data) > $signed(id_stage_bus.rs2_data);
            LTU:        comparison_result = $unsigned(id_stage_bus.rs1_data) < $unsigned(id_stage_bus.rs2_data);
            GEU:        comparison_result = $unsigned(id_stage_bus.rs1_data) > $unsigned(id_stage_bus.rs2_data);
            default:    comparison_result = '0;
        endcase
    end
endmodule