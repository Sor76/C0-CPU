`timescale 1ns/1ps

module PC
    import ControlSignals_pkg::*;
(
    FetchStageBus.master if_stage_bus,
    WritebackStageBus.slave wb_stage_bus
);
    // Address selcting
    always_comb begin
        case (wb_stage_bus.pc_src)
            PCSRC_NEXT_ADDRESS:         if_stage_bus.selected_address = if_stage_bus.address + 4;
            PCSRC_JUMP_ADDRESS:         if_stage_bus.selected_address = wb_stage_bus.alu_result;
            PCSRC_JUMP_JALR_ADDRESS:    if_stage_bus.selected_address = wb_stage_bus.alu_result[31:1] << 1'b1;
            default:                    if_stage_bus.selected_address = if_stage_bus.address;
        endcase
    end

    // Updating address register
    always_ff @(posedge if_stage_bus.clk or negedge if_stage_bus.rst_n) begin
        if_stage_bus.address <= (!if_stage_bus.rst_n) ? '0 : if_stage_bus.selected_address;
    end
endmodule