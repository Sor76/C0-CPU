`timescale 1ns/1ps

module InstructionMemoryController #(
    parameter int       ADDRESS_WIDTH   = 16, // In bit
    parameter string    PROGRAM_NAME    = "program.mem"
) (
    FetchStageBus.master if_stage_bus
);
    // Using Byte addressable memory for instruction (1 address = 1 byte)
    // Total instruction count = 2 ** ADDRESS_WIDTH / 4
    // Byte addressable memory because "sometimes" the PC address will land on ...10, which will make 4 bytes read on Word addressable memory pretty hard/required more clock cycle.
    // It would be easier to use Byte addressable memory that always read 4 bytes from any address.
    (* ram_style = "block" *) logic [7:0] instruction_memory_block [0:2**ADDRESS_WIDTH - 1] = '{default: 0};

    // Read a program from a file with the name of PROGRAM_NAME parameter using base 16.
    // Per line, there would be 8 hex values. Those values are group into 4 group (2 per group) separate by space.
    // Else the $readmemh will ignore 00 value.
    // 
    // Example:
    // lui t0, 1
    // addi zero, zero, 0
    // addi zero, zero, 0
    // slli t0, t0, 10
    // For binary that would be (same bit organization as the instruction format table)
    // 00000000000000000001001010110111
    // 00000000000000000000000000010011
    // 00000000000000000000000000010011
    // 00000000101000101001001010010011
    // Converting into hex format that $readmemh could read would be
    // 00 00 12 B7
    // 00 00 00 13
    // 00 00 00 13
    // 00 A2 92 93
    // 
    // Now we have to reverse the order because of the RISC-V specification did specify that memory should use little-endian (LSB is in the front, MSB in the back).
    // B7 12 00 00
    // 13 00 00 00
    // 13 00 00 00
    // 93 92 A2 00

    initial begin
        $readmemh(PROGRAM_NAME, instruction_memory_block);
    end

    always_ff @(posedge if_stage_bus.clk) begin
        // Use selected_address instead of PC's current address to combat the synchronous read of BRAM.
        // Convert the little-endian in to big-endian instruction because I already designs most of the processor to be big-endian before knowing the little-endian thing. lol
        if_stage_bus.instruction <= {<<8{instruction_memory_block[if_stage_bus.selected_address +:4]}};
    end
endmodule