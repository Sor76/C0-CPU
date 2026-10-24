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
    // Using Byte addressable memory for instruction (1 address = 1 byte)
    // Total instruction count = 2 ** ADDRESS_WIDTH / 4
    // Byte addressable memory because "sometimes" the PC address will land on ...10, which will make 4 bytes read on Word addressable memory pretty hard/required more clock cycle.
    // It would be easier to use Byte addressable memory that always read 4 bytes from any address.
    (* ram_style = "block" *) Byte inst_mem_block_1 [0:2**(ADDRESS_WIDTH >> 2) - 1];
    (* ram_style = "block" *) Byte inst_mem_block_2 [0:2**(ADDRESS_WIDTH >> 2) - 1];
    (* ram_style = "block" *) Byte inst_mem_block_3 [0:2**(ADDRESS_WIDTH >> 2) - 1];
    (* ram_style = "block" *) Byte inst_mem_block_4 [0:2**(ADDRESS_WIDTH >> 2) - 1];
    Byte block_1_out;
    Byte block_2_out;
    Byte block_3_out;
    Byte block_4_out;

    logic [8:0] read_temp [0:2**ADDRESS_WIDTH-1];
    initial begin
        $readmemh(PROGRAM_NAME, read_temp);

        for (int i = 0; i < 2**(ADDRESS_WIDTH >> 2); i = i + 1) begin
            inst_mem_block_1[i] = read_temp[i * 4];
            inst_mem_block_2[i] = read_temp[i * 4 + 1];
            inst_mem_block_3[i] = read_temp[i * 4 + 2];
            inst_mem_block_4[i] = read_temp[i * 4 + 3];
        end

        block_1_out = inst_mem_block_1[0];
        block_2_out = inst_mem_block_2[0];
        block_3_out = inst_mem_block_3[0];
        block_4_out = inst_mem_block_4[0];
        instruction = {block_4_out, block_3_out, block_2_out, block_1_out};
    end

    always_comb begin
        case (selected_address[1:0])
            2'b00:      instruction = {block_1_out, block_2_out, block_3_out, block_4_out};
            2'b01:      instruction = {block_2_out, block_3_out, block_4_out, block_1_out};
            2'b10:      instruction = {block_3_out, block_4_out, block_1_out, block_2_out};
            2'b11:      instruction = {block_4_out, block_1_out, block_2_out, block_3_out};
            default:    instruction = '0; // Will be turn into NOP
        endcase
    end
    always_ff @(posedge clk) begin
        // Use selected_address instead of PC's current address to combat the synchronous read of BRAM.
        // Convert the little-endian in to big-endian instruction because I already designs most of the processor to be big-endian before knowing the little-endian thing. lol
        block_1_out <= (selected_address[1:0] > 0) ? inst_mem_block_1[selected_address[31:2] + 1] : inst_mem_block_1[selected_address[31:2]];
        block_2_out <= (selected_address[1:0] > 1) ? inst_mem_block_2[selected_address[31:2] + 1] : inst_mem_block_2[selected_address[31:2]];
        block_3_out <= (selected_address[1:0] > 2) ? inst_mem_block_3[selected_address[31:2] + 1] : inst_mem_block_3[selected_address[31:2]];
        block_4_out <= inst_mem_block_4[selected_address[31:2]];
        
        // case (selected_address[1:0])
        //     2'b00: begin
        //         block_1_out <= inst_mem_block_1[selected_address[31:2]];
        //         block_2_out <= inst_mem_block_2[selected_address[31:2]];
        //         block_3_out <= inst_mem_block_3[selected_address[31:2]];
        //         block_4_out <= inst_mem_block_4[selected_address[31:2]];
        //     end
        //     2'b01: begin
        //         block_1_out <= inst_mem_block_1[selected_address[31:2] + 1];
        //         block_2_out <= inst_mem_block_2[selected_address[31:2]];
        //         block_3_out <= inst_mem_block_3[selected_address[31:2]];
        //         block_4_out <= inst_mem_block_4[selected_address[31:2]];
        //     end
        //     2'b10: begin
        //         block_1_out <= inst_mem_block_1[selected_address[31:2] + 1];
        //         block_2_out <= inst_mem_block_2[selected_address[31:2] + 1];
        //         block_3_out <= inst_mem_block_3[selected_address[31:2]];
        //         block_4_out <= inst_mem_block_4[selected_address[31:2]];
        //     end
        //     2'b11: begin
        //         block_1_out <= inst_mem_block_1[selected_address[31:2] + 1];
        //         block_2_out <= inst_mem_block_2[selected_address[31:2] + 1];
        //         block_3_out <= inst_mem_block_3[selected_address[31:2] + 1];
        //         block_4_out <= inst_mem_block_4[selected_address[31:2]];
        //     end
        // endcase
    end
endmodule