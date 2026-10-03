`timescale 1ns/1ps

module RegisterFileMux
    import ControlSignals_pkg::*;
(
    WritebackStageBus.master wb_stage_bus,
    MemoryStageBus.slave mem_stage_bus
);
    always_comb begin
        case (mem_stage_bus.rd_src)
            RDSRC_ALU_RESULT:       wb_stage_bus.rd_write_data = mem_stage_bus.alu_result;
            RDSRC_NEXT_ADDRESS:     wb_stage_bus.rd_write_data = mem_stage_bus.next_address;
            RDSRC_DEVICE_READ_DATA: wb_stage_bus.rd_write_data = wb_stage_bus.device_extended_data;
            default:                wb_stage_bus.rd_write_data = '0;
        endcase
    end
endmodule   