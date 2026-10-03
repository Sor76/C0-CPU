`timescale 1ns/1ps

module DeviceDataMux
    import ControlSignals_pkg::*;
(
    WritebackStageBus.master wb_stage_bus,
    MemoryStageBus.slave mem_stage_bus
);
    always_comb begin
        case (mem_stage_bus.device_data_src)
            DEVICE_DATA_SRC_DATA_MEM:           wb_stage_bus.device_data = mem_stage_bus.data_mem_read_data;
            DEVICE_DATA_SRC_LCD_CONTROLLER:     wb_stage_bus.device_data = mem_stage_bus.lcd_read_data;
            DEVICE_DATA_SRC_BUTTON_CONTROLLER:  wb_stage_bus.device_data = mem_stage_bus.button_read_data;
            default:                            wb_stage_bus.device_data = '0;
        endcase
    end
endmodule