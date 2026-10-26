`timescale 1ns/1ps

module DataMemoryController
    import ControlSignals_pkg::*;
    import Types_pkg::*;
#(
    parameter int ADDRESS_WIDTH         = 16
) (
    input logic                         clk,
    input logic                         rst_n,

    input  logic                        device_select,
    input  logic [ADDRESS_WIDTH-1:0]    device_address,
    input  Word                         write_data,
    input  WriteOp                      validated_write_op,

    output Word                         data_out
);
    // Using Word addressable memory (1 word = 4 bytes) with one of the worst way to store data.
    // 1 address = 1 data (no matter if it is 1, 2 or 4 bytes). Always read/write 4 bytes at a time no matter if the instruction was 1, 2 or 4 bytes access.
    // This method prevent unalign memory access, and enable up to 4 bytes read/write operation in one cycle.
    // At the cost of breaking RISC-V specification (must support unalign memory access) and horrible space efficiency.

    // BRAM part
    // Lower block index = the more "MSB" it would be (for 4  byte alignment).
    (* ram_style = "block" *) Byte data_memory_block_1 [0:2**(ADDRESS_WIDTH - 2) - 1] = '{default: 0};
    (* ram_style = "block" *) Byte data_memory_block_2 [0:2**(ADDRESS_WIDTH - 2) - 1] = '{default: 0};
    (* ram_style = "block" *) Byte data_memory_block_3 [0:2**(ADDRESS_WIDTH - 2) - 1] = '{default: 0};
    (* ram_style = "block" *) Byte data_memory_block_4 [0:2**(ADDRESS_WIDTH - 2) - 1] = '{default: 0};
    logic [ADDRESS_WIDTH-1:0]   block_addr          [0:3];
    logic                       block_we            [0:3];
    Byte                        block_write_data    [0:3];
    Byte                        block_out           [0:3];
    
    always_ff @(posedge clk) begin
        if (block_we[0]) data_memory_block_1[block_addr[0]] <= block_write_data[0];
        if (block_we[1]) data_memory_block_2[block_addr[1]] <= block_write_data[1];
        if (block_we[2]) data_memory_block_3[block_addr[2]] <= block_write_data[2];
        if (block_we[3]) data_memory_block_4[block_addr[3]] <= block_write_data[3];

        block_out[0] <= data_memory_block_1[block_addr[0]];
        block_out[1] <= data_memory_block_2[block_addr[1]];
        block_out[2] <= data_memory_block_3[block_addr[2]];
        block_out[3] <= data_memory_block_4[block_addr[3]];
    end


    // BRAM resetting part
    logic                           is_resetting        = 0;
    logic [(ADDRESS_WIDTH - 2)-1:0] resetting_counter   = '0;
    always_ff @(posedge clk) begin
        if (is_resetting) begin
            if (resetting_counter == 2**(ADDRESS_WIDTH - 2)-1) begin
                resetting_counter <= '0;
                is_resetting <= 0;
            end else begin
                resetting_counter <= resetting_counter + 1;
            end
        end else if (!rst_n) begin
            is_resetting <= 1;
            resetting_counter <= '0;
        end
    end

    // BRAM Normal operation part
    // Address Decoder already handles the conflicting of read and write operation.
    initial data_out = '0;
    always_comb begin
        if (is_resetting) begin
            block_addr          = '{default: resetting_counter};
            block_we            = '{default: 1};
            block_write_data    = '{default: 0};
            data_out            = '0;
        end else begin
            // Missalign address handling
            block_addr[0] = device_address[ADDRESS_WIDTH-1:2];
            block_addr[1] = (device_address[1:0] > 2) ? device_address[ADDRESS_WIDTH-1:2] + 1 : device_address[ADDRESS_WIDTH-1:2];
            block_addr[2] = (device_address[1:0] > 1) ? device_address[ADDRESS_WIDTH-1:2] + 1 : device_address[ADDRESS_WIDTH-1:2];
            block_addr[3] = (device_address[1:0] > 0) ? device_address[ADDRESS_WIDTH-1:2] + 1 : device_address[ADDRESS_WIDTH-1:2];

            // Writing
            if (device_select) begin
                // Creating one write data line
                // Convert big endian into little endian for storing
                case (device_address[1:0])
                    2'b00:      block_write_data = {write_data[7:0],    write_data[15:8],   write_data[23:16],  write_data[31:24]};
                    2'b01:      block_write_data = {write_data[31:24],  write_data[7:0],    write_data[15:8],   write_data[23:16]};
                    2'b10:      block_write_data = {write_data[23:16],  write_data[31:24],  write_data[7:0],    write_data[15:8]};
                    2'b11:      block_write_data = {write_data[15:8],   write_data[23:16],  write_data[31:24],  write_data[7:0]};
                    default:    block_write_data = '{default: 0};
                endcase

                // Masking the write dat aline
                // 00 = 1, 0, 0, 0
                // 01 = 0, 1, 0, 0
                // 10 = 0, 0, 1, 0
                // 11 = 0, 0, 0, 1

                // 00 = 1, 1, 0, 0
                // 01 = 0, 1, 1, 0
                // 10 = 0, 0, 1, 1
                // 11 = 1, 0, 0, 1
                case (validated_write_op)
                    WRITE_OP_1_BYTE:    block_we = {<<{4'b1000 >> device_address[1:0]}};
                    WRITE_OP_2_BYTES:   block_we = {<<{4'b1000 >> device_address[1:0] | (device_address[1:0] == 2'b11) ? 4'b1000 : 4'b0000}};
                    WRITE_OP_4_BYTES:   block_we = '{default: 1};
                    default:            block_we = '{default: 0};
                endcase
            end else begin
                block_write_data    = '{default: 0};
                block_we            = '{default: 0};
            end

            // Reading
            // Convert little endian into big endian for internal processing
            case (device_address[1:0])
                2'b00:      data_out = {block_out[3], block_out[2], block_out[1], block_out[0]};
                2'b01:      data_out = {block_out[0], block_out[3], block_out[2], block_out[1]};
                2'b10:      data_out = {block_out[1], block_out[0], block_out[3], block_out[2]};
                2'b11:      data_out = {block_out[2], block_out[1], block_out[0], block_out[3]};
                default:    data_out = '0;
            endcase
        end
    end
endmodule