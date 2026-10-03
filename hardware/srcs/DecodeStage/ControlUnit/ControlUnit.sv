`timescale 1ns/1ps

module ControlUnit (
    DecodeStageBus.master id_stage_bus,
    FetchStageBus.slave if_stage_bus
);
    InstructionDecoder inst_decoder (
        .id_stage_bus(id_stage_bus),
        .if_stage_bus(if_stage_bus)
    );
    OperationDecoder op_decoder (
        .id_stage_bus(id_stage_bus)
    );
endmodule