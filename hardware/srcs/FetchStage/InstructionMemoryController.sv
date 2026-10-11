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
    (* ram_style = "block" *) logic [7:0] instruction_memory_block [0:2**ADDRESS_WIDTH - 1];

    initial begin
        $readmemh(PROGRAM_NAME, instruction_memory_block);
        instruction = {<<8{instruction_memory_block[0:3]}};
    end

    always_ff @(posedge clk) begin
        // Use selected_address instead of PC's current address to combat the synchronous read of BRAM.
        // Convert the little-endian in to big-endian instruction because I already designs most of the processor to be big-endian before knowing the little-endian thing. lol
        instruction <= {
            instruction_memory_block[selected_address+3],
            instruction_memory_block[selected_address+2],
            instruction_memory_block[selected_address+1],
            instruction_memory_block[selected_address]
        };
    end
endmodule