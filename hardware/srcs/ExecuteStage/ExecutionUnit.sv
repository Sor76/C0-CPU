`timescale 1ns/1ps

module ExecutionUnit
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    ExecuteStageBus.master ex_stage_bus,
    DecodeStageBus.slave id_stage_bus
);
    assign ex_stage_bus.next_address = id_stage_bus.current_address + 4;

    ALU alu (
        .ex_stage_bus(ex_stage_bus),
        .id_stage_bus(id_stage_bus)
    );
    JmpHandler jmp_handler (
        .ex_stage_bus(ex_stage_bus),
        .id_stage_bus(id_stage_bus)
    );

    // Operand mux
    always_comb begin
        case (id_stage_bus.alu_operand[0])
            1'b0: ex_stage_bus.operand_1 = id_stage_bus.rs1_data;
            1'b1: ex_stage_bus.operand_1 = id_stage_bus.current_address;
        endcase
        case (id_stage_bus.alu_operand[1])
            1'b0: ex_stage_bus.operand_2 = id_stage_bus.rs2_data;
            1'b1: ex_stage_bus.operand_2 = id_stage_bus.extended_imm;
        endcase
    end
endmodule