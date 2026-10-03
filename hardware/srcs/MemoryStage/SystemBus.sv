`timescale 1ns/1ps

module SystemBus
    import ControlSignals_pkg::*;
#(
    parameter int DATA_MEM_ADDRESS_WIDTH    = 16,
    parameter int BUTTON_ROWS               = 5,
    parameter int BUTTON_COLS               = 4
) (
    // Processor internal buses
    MemoryStageBus.master   mem_stage_bus,
    MemoryStageBus.device   device_bus,
    ExecuteStageBus.slave   ex_stage_bus,

    // Processor-Peripheral external buses
    LCDDeviceBus.master     lcd_bus,
    ButtonDeviceBus.master  button_bus
);
    AddressDecoder address_decoder (
        .mem_stage_bus(mem_stage_bus),
        .ex_stage_bus(ex_stage_bus)
    );

    // Devices
    DataMemoryController #(
        .ADDRESS_WIDTH(DATA_MEM_ADDRESS_WIDTH)
    ) data_memory_controller (
        .device_bus(device_bus)
    );
    LCDController lcd_controller (
        .device_bus(device_bus),
        .lcd_bus(lcd_bus)
    );
    ButtonController #(
        .BUTTON_ROWS(BUTTON_ROWS),
        .BUTTON_COLS(BUTTON_COLS)
    ) button_controller (
        .device_bus(device_bus),
        .button_bus(button_bus)
    );
endmodule