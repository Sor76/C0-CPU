`timescale 1ns/1ps

module InstructionMemoryController
    import Types_pkg::*;
#(
    parameter int       ADDRESS_WIDTH   = 16, // In bit
    parameter string    PROGRAM_NAME    = "program.mem"
) (
    input   logic   clk,
    input   Word    selected_address,
    output  Word    instruction
);
    // Total instruction count = 2 ** ADDRESS_WIDTH / 4
    // Block 1 holds the MSB of the instruction, and block 4 holds the LSB. This is in little endian format.
    (* ram_style = "block" *) Byte inst_mem_block_1 [0:2**(ADDRESS_WIDTH - 2) - 1];
    (* ram_style = "block" *) Byte inst_mem_block_2 [0:2**(ADDRESS_WIDTH - 2) - 1];
    (* ram_style = "block" *) Byte inst_mem_block_3 [0:2**(ADDRESS_WIDTH - 2) - 1];
    (* ram_style = "block" *) Byte inst_mem_block_4 [0:2**(ADDRESS_WIDTH - 2) - 1];
    Word    block_addr [0:3];
    Byte    block_out  [0:3];

    logic [8:0] read_temp [0:2**ADDRESS_WIDTH-1];
    initial begin
        $readmemh(PROGRAM_NAME, read_temp);

        for (int i = 0; i < 2**(ADDRESS_WIDTH - 2); i = i + 1) begin
            // Write to memory block as little endian
            inst_mem_block_1[i] = read_temp[i * 4];
            inst_mem_block_2[i] = read_temp[i * 4 + 1];
            inst_mem_block_3[i] = read_temp[i * 4 + 2];
            inst_mem_block_4[i] = read_temp[i * 4 + 3];
        end

        block_out[0] = inst_mem_block_1[0];
        block_out[1] = inst_mem_block_2[0];
        block_out[2] = inst_mem_block_3[0];
        block_out[3] = inst_mem_block_4[0];
        instruction = {block_out[3], block_out[2], block_out[1], block_out[0]};
    end

    always_comb begin
        // Misglignment address handling
        // Use selected_address instead of PC's current address to combat the synchronous read of BRAM.
        block_addr[0] = selected_address[ADDRESS_WIDTH-1:2];
        block_addr[1] = (selected_address[1:0] > 2) ? selected_address[ADDRESS_WIDTH-1:2] + 1 : selected_address[ADDRESS_WIDTH-1:2];
        block_addr[2] = (selected_address[1:0] > 1) ? selected_address[ADDRESS_WIDTH-1:2] + 1 : selected_address[ADDRESS_WIDTH-1:2];
        block_addr[3] = (selected_address[1:0] > 0) ? selected_address[ADDRESS_WIDTH-1:2] + 1 : selected_address[ADDRESS_WIDTH-1:2];

        // Convert the little-endian in to big-endian instruction because I already designs most of the processor to be big-endian before knowing the little-endian thing. lol
        case (selected_address[1:0])
            2'b00:      instruction = {block_out[3], block_out[2], block_out[1], block_out[0]};
            2'b01:      instruction = {block_out[0], block_out[3], block_out[2], block_out[1]};
            2'b10:      instruction = {block_out[1], block_out[0], block_out[3], block_out[2]};
            2'b11:      instruction = {block_out[2], block_out[1], block_out[0], block_out[3]};
            default:    instruction = '0; // Will be turn into NOP
        endcase
    end
    always_ff @(posedge clk) begin
        block_out[0] <= inst_mem_block_1[block_addr[0]];
        block_out[1] <= inst_mem_block_2[block_addr[1]];
        block_out[2] <= inst_mem_block_3[block_addr[2]];
        block_out[3] <= inst_mem_block_4[block_addr[3]];
    end
endmodule