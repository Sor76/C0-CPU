`timescale 1ns/1ps

module InstructionMemory_tb;
    logic [31:0] address = 0;
    logic [31:0] instruction;

    InstructionMemory #(
        .INSTRUCTION_COUNTS(1024),
        .PROGRAM_NAME("test.mem")
    ) dut (
        .address(address),
        .instruction(instruction)
    );

    // Need to manually check the matching between the instruction output and instructions inside test.mem.
    // Could use python or other programming language to generate the test .mem file,
    // but have to change the testbench too then.
    initial begin
        repeat (1000) begin
            #1ns;
            address = address + 4; 
        end
        $finish;
    end
endmodule