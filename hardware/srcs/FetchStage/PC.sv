`timescale 1ns/1ps

module PC
    import ControlSignals_pkg::*;
(
    FetchStageBus.master fetch_stage_bus,
    MemoryStageBus.slave memory_stage_bus
);
    initial fetch_stage_bus.address = 0;

    always_ff @(posedge fetch_stage_bus.clk or negedge fetch_stage_bus.rst_n) begin
        if (!fetch_stage_bus.rst_n) begin
            fetch_stage_bus.address <= 0;
        end else begin
            case (memory_stage_bus.pc_src)
                PCSRC_NEXT_ADDRESS: fetch_stage_bus.address <= fetch_stage_bus.address + 4;
                PCSRC_JUMP_ADDRESS: fetch_stage_bus.address <= memory_stage_bus.jump_address;
                PCSRC_JUMP_JALR_ADDRESS: fetch_stage_bus.address <= {memory_stage_bus.jump_address[31:1], 1'b0};
            endcase
        end
    end
endmodule