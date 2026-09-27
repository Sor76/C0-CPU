`timescale 1ns/1ps

interface PCTbInterface
    import ControlSignals_pkg::*;
();
    
    logic clk;
    logic rst_n;

    PCSrc pc_src;
    logic [31:0] jump_address;
    logic [31:0] address;

    modport master (
        input address,
        output clk, rst_n, pc_src, jump_address
    );
    modport slave (
        input clk, rst_n, pc_src, jump_address,
        output address
    );
endinterface

program PCTbProgram (
    PCTbInterface.master bus
);
    localparam TEST_ROUND_PER_STAGE = 2 ** 24;

    task automatic reset_pc();
        bus.rst_n = 0;
        #1ns;
        bus.rst_n = 1;
    endtask

    // Clock initialization
    initial begin
        bus.clk = 0;
        forever #1ns bus.clk = !bus.clk;
    end

    // Reset PC after every test stage
    int random_jump_address;
    int counting_reference;
    initial begin
        reset_pc();
        assert (bus.address == 0) else $fatal(4, "Unable to reset PC's address.");

        // Normal counting stage
        bus.pc_src = PCSRC_NEXT_ADDRESS;
        counting_reference = 0;
        repeat (TEST_ROUND_PER_STAGE) begin
            assert (counting_reference == bus.address) else $fatal(1, "Mismatch between expected address and PC's address in counting stage. Expected: %h, Got: %h.", counting_reference, bus.address);
            @(posedge bus.clk);
            counting_reference = counting_reference + 4;
        end
        reset_pc();
        assert (bus.address == 0) else $fatal(4, "Unable to reset PC's address.");
        $display("PASSED normal counting stage.");

        // Jump address stage
        bus.pc_src = PCSRC_JUMP_ADDRESS;
        repeat (TEST_ROUND_PER_STAGE) begin
            assert (std::randomize(random_jump_address)) else $fatal(5, "Unable to randomize new jump address value.");
            bus.jump_address = random_jump_address;
            @(negedge bus.clk);
            assert (random_jump_address == bus.address) else $fatal(2, "Mismatch between PC's address and the random jump address in jump address stage. Expected: %h, Got: %h.", random_jump_address, bus.address);
        end
        reset_pc();
        assert (bus.address == 0) else $fatal(4, "Unable to reset PC's address.");
        $display("PASSED jump address stage.");

        // JALR Jump address stage
        bus.pc_src = PCSRC_JUMP_JALR_ADDRESS;
        repeat (TEST_ROUND_PER_STAGE) begin
            assert (std::randomize(random_jump_address)) else $fatal(5, "Unable to randomize new jump address value.");
            bus.jump_address = random_jump_address;
            @(negedge bus.clk);
            assert ({random_jump_address[31:1], 1'b0} == bus.address) else $fatal(3, "Mismatch between PC's address and the JALR random jump address in JALR jump address stage. Expected: %b, Got: %b.", {random_jump_address[31:1], 1'b0}, bus.address);
        end
        reset_pc();
        assert (bus.address == 0) else $fatal(4, "Unable to reset PC's address.");
        $display("PASSED JALR jump address stage.");

        $display("PASSED all test.");
        $finish;
    end
endprogram

module PC_tb;
    PCTbInterface bus();
    PC dut (
        .clk(bus.slave.clk),
        .rst_n(bus.slave.rst_n),
        .pc_src(bus.slave.pc_src),
        .jump_address(bus.slave.jump_address),
        .address(bus.slave.address)
    );
    PCTbProgram test_env (
        .bus(bus.master)
    );
endmodule