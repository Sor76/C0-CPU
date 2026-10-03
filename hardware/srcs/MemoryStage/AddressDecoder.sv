`timescale 1ns/1ps

module AddressDecoder
    import ControlSignals_pkg::*;
#(
    parameter int DEVICE_COUNTS = 3 // Data Memory + LCD Controller + Button Controller
) (
    MemoryStageBus.master   mem_stage_bus,
    ExecuteStageBus.slave   ex_stage_bus
);
    // Behavior of the processor try to read and write at the same time.
    ReadOp validated_read_op;
    WriteOp validated_write_op;
    assign validated_read_op = (ex_stage_bus.read_op != NO_READ_OP && ex_stage_bus.write_op != NO_WRITE_OP) ? NO_READ_OP : ex_stage_bus.read_op;
    assign validated_write_op = (ex_stage_bus.read_op != NO_READ_OP && ex_stage_bus.write_op != NO_WRITE_OP) ? NO_WRITE_OP : ex_stage_bus.write_op;

    always_comb begin
        mem_stage_bus.device_select     = {>>{'0 | (1'b1 << ex_stage_bus.alu_result[31:32-$clog2(DEVICE_COUNTS)])}};
        mem_stage_bus.address           = ex_stage_bus.alu_result[31-$clog2(DEVICE_COUNTS):0];
        mem_stage_bus.write_data        = ex_stage_bus.rs2_data;
        mem_stage_bus.read_op           = validated_read_op;
        mem_stage_bus.write_op          = validated_write_op;

        mem_stage_bus.device_data_src   = DeviceDataSrc'(ex_stage_bus.alu_result[31:32-$clog2(DEVICE_COUNTS)]);
    end
endmodule