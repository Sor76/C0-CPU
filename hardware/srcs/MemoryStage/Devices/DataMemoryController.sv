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
    input  ReadOp                       validated_read_op,
    input  WriteOp                      validated_write_op,

    output Word                         data_out
);
    // Using Word addressable memory (1 word = 4 bytes) with one of the worst way to store data.
    // 1 address = 1 data (no matter if it is 1, 2 or 4 bytes). Always read/write 4 bytes at a time no matter if the instruction was 1, 2 or 4 bytes access.
    // This method prevent unalign memory access, and enable up to 4 bytes read/write operation in one cycle.
    // At the cost of breaking RISC-V specification (must support unalign memory access) and horrible space efficiency.

    // BRAM part
    (* ram_style = "block" *) Word data_memory_block [0:2**ADDRESS_WIDTH - 1] = '{default: 0};
    logic [ADDRESS_WIDTH-1:0]   bram_addr = '0;
    logic                       bram_we = 0;
    // logic                       bram_re = 0;
    Word                        bram_write_data = '0;
    Word                        bram_read_reg = '0;
    always_ff @(posedge clk) begin
        if (bram_we) begin
            data_memory_block[bram_addr] <= bram_write_data;
        end
        // bram_read_reg <= (bram_re) ? data_memory_block[bram_addr] : '0;
        bram_read_reg <= data_memory_block[bram_addr];
    end


    // BRAM Controller part
    logic                       is_resetting = 0;
    logic [ADDRESS_WIDTH-1:0]   resetting_counter = '0;
    always_ff @(posedge clk) begin
        if (is_resetting) begin
            if (resetting_counter == 2**ADDRESS_WIDTH-1) begin
                resetting_counter <= '0;
                is_resetting <= 0;
            end else begin
                resetting_counter <= resetting_counter + 4;
            end
        end else if (!rst_n) begin
            is_resetting <= 1;
            resetting_counter <= '0;
        end
    end

    // Address Decoder already handles the conflicting of read and write operation.
    // Forcing read/write 4-byte at a times. For read operation, the Bit Extender will handle the 1-2 bytes read. For write operation, some byte will be 0.
    always_comb begin
        if (is_resetting) begin
            bram_addr       = resetting_counter;
            bram_we         = 1;
            // bram_re         = 0;
            bram_write_data = '0;
            data_out        = '0;
        end else begin
            bram_addr       = device_address;
            bram_we         = (validated_write_op inside {[WRITE_OP_1_BYTE : WRITE_OP_4_BYTES]}) ? 1 : 0;

            case (validated_write_op)
                WRITE_OP_1_BYTE:    bram_write_data = {write_data[7:0], 24'h0};
                WRITE_OP_2_BYTES:   bram_write_data = {<<8{16'h0, write_data[15:0]}};
                WRITE_OP_4_BYTES:   bram_write_data = {<<8{write_data}};
                default:            bram_write_data = '0;
            endcase
            
            data_out = (validated_read_op inside {[READ_OP_1_U_BYTE : READ_OP_2_BYTES]}) ? {<<8{bram_read_reg}} : '0;
            // if (validated_read_op inside {[READ_OP_1_U_BYTE : READ_OP_2_BYTES]}) begin
            //     bram_re = 1;
            //     data_out = {<<8{bram_read_reg}};
            // end else begin
            //     bram_re = 0;
            //     data_out = '0;
            // end
        end
    end
    initial data_out = '0;
endmodule