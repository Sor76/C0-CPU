`timescale 1ns/1ps

module AddressDecoder
    import ControlSignals_pkg::*;
    import Types_pkg::*;
#(
    parameter int DEVICE_COUNTS = 5 // Data Memory + LCD Controller + Button Controller
) (
    input   Word                                alu_result,
    input   ReadOp                              read_op,
    input   WriteOp                             write_op,

    output  logic                               device_select [DEVICE_COUNTS-1:0],
    output  logic [31-$clog2(DEVICE_COUNTS):0]  device_address,
    output  ReadOp                              validated_read_op,
    output  WriteOp                             validated_write_op,
    output  DeviceDataSrc                       device_data_src
);
    assign device_select        = {>>{{DEVICE_COUNTS{1'b0}} | (1'b1 << alu_result[31:32-$clog2(DEVICE_COUNTS)])}};
    assign device_address       = alu_result[31-$clog2(DEVICE_COUNTS):0];
    assign device_data_src      = DeviceDataSrc'(alu_result[31:32-$clog2(DEVICE_COUNTS)]);

    // Behavior of the processor try to read and write at the same time.
    assign validated_read_op    = (read_op != NO_READ_OP && write_op != NO_WRITE_OP) ? NO_READ_OP : read_op;
    assign validated_write_op   = (read_op != NO_READ_OP && write_op != NO_WRITE_OP) ? NO_WRITE_OP : write_op;
endmodule