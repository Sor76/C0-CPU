`timescale 1ns/1ps

module Top (
    input logic clk,
    input logic rst_n
);
    // Fetch Stage
    FetchInterstageBus fetch_interstage_bus (
        .clk(clk),
        .rst_n(rst_n)
    );
    PC pc (

    );
    InstructionMemory instruction_memory (

    );

    // Decode Stage
    // Execute Stage
    // Memory Stage
    // Writeback Stage
endmodule