`timescale 1ns/1ps

module DataMemoryController
    import ControlSignals_pkg::*;
#(
    parameter int ADDRESS_WIDTH         = 16,
    parameter int DEVICE_SELECT_NUMBER  = 0
) (
    MemoryStageBus.device device_bus
);
    // Using Word addressable memory (1 word = 4 bytes) with one of the worst way to store data.
    // 1 address = 1 data (no matter if it is 1, 2 or 4 bytes). Always read/write 4 bytes at a time no matter if the instruction was 1, 2 or 4 bytes access.
    // This method prevent unalign memory access, and enable up to 4 bytes read/write operation in one cycle.
    // At the cost of breaking RISC-V specification (must support unalign memory access) and horrible space efficiency.
    (* ram_style = "block" *) logic [31:0] data_memory_block [0:2**ADDRESS_WIDTH - 1] = '{default: 0};


    // Address Decoder already handles the conflicting of read and write operation.
    // Forcing read/write 4-byte at a times. For read operation, the Bit Extender will handle the 1-2 bytes read. For write operation, some byte will be 0.
    logic is_resetting = 1'b0;
    logic [ADDRESS_WIDTH-1:0] resetting_counter = '0;
    always_ff @(posedge device_bus.clk) begin
        if (!is_resetting) begin
            if (!device_bus.rst_n) begin
                // Initiate reset sequence
                is_resetting <= 1'b1;
            end else if (device_bus.device_select[DEVICE_SELECT_NUMBER]) begin
                // Read operation
                case (device_bus.read_op) inside
                    [READ_OP_1_U_BYTE : READ_OP_2_BYTES]:   device_bus.data_mem_read_data <= {<<8{data_memory_block[device_bus.address]}};
                    default:                                device_bus.data_mem_read_data <= '0;
                endcase

                // Write operation
                case (device_bus.write_op)
                    WRITE_OP_1_BYTE:    data_memory_block[device_bus.address] <= {device_bus.write_data[7:0], 24'h0};
                    WRITE_OP_2_BYTES:   data_memory_block[device_bus.address] <= {<<8{16'h0, device_bus.write_data[15:0]}};
                    WRITE_OP_4_BYTES:   data_memory_block[device_bus.address] <= {<<8{device_bus.write_data}};
                endcase
            end else begin
                // Default to output a 0 if not selected.
                device_bus.data_mem_read_data <= '0;
            end
        end else begin
            data_memory_block[resetting_counter] <= '0;
            resetting_counter <= resetting_counter + 1;

            if (resetting_counter == 2**ADDRESS_WIDTH - 1) is_resetting <= '0;
        end
    end
endmodule