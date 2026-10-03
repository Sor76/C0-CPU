`timescale 1ns/1ps

module BitExtender
    import ControlSignals_pkg::*;
(
    WritebackStageBus.master wb_stage_bus,
    MemoryStageBus.slave mem_stage_bus
);
    always_comb begin
        case (mem_stage_bus.read_op)
            READ_OP_1_U_BYTE:   wb_stage_bus.device_extended_data = $unsigned(wb_stage_bus.device_data[7:0]);
            READ_OP_2_U_BYTES:  wb_stage_bus.device_extended_data = $unsigned(wb_stage_bus.device_data[15:0]);

            READ_OP_1_BYTE:     wb_stage_bus.device_extended_data = $signed(wb_stage_bus.device_data[7:0]);
            READ_OP_2_BYTES:    wb_stage_bus.device_extended_data = $signed(wb_stage_bus.device_data[15:0]);

            READ_OP_4_BYTES:    wb_stage_bus.device_extended_data = wb_stage_bus.device_data;

            default:            wb_stage_bus.device_extended_data = '0;
        endcase
    end
endmodule