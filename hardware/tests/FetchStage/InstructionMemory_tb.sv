`timescale 1ns/1ps

module InstructionMemory_tb;
    localparam int ADDRESS_WIDTH = 8;

    logic clk;
    logic rst_n = 1;

    logic [ADDRESS_WIDTH-1:0] selected_address = 0;
    logic [31:0] instruction;


    FetchStageBus if_stage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    assign if_stage_bus.master.selected_address = selected_address;
    assign instruction = if_stage_bus.master.instruction;

    InstructionMemoryController #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .PROGRAM_NAME("test.mem")
    ) dut (
        .if_stage_bus(if_stage_bus)
    );

    // Need to manually check the matching between the instruction output and instructions inside test.mem.
    // Could use python or other programming language to generate the test .mem file,
    // but have to change the testbench too then.
    initial begin
        clk = 0;
        forever #1ns clk = !clk;
    end
    initial begin
        repeat (2**ADDRESS_WIDTH) begin
            @(negedge clk);
            selected_address = selected_address + 4;
        end
        $finish;
    end
endmodule