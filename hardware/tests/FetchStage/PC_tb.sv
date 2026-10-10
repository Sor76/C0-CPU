`timescale 1ns/1ps

program PCTbProgram #(
    parameter int TEST_SIZE_PER_STAGE = 2 ** 24
) (
    output logic clk,
    output logic rst_n,
    WritebackStageBus.master wb_stage_bus,
    FetchStageBus.slave if_stage_bus
);
    task automatic reset();
        rst_n = 0;
        #1ns;
        rst_n = 1;
    endtask

    // Signal init
    initial begin
        rst_n = 1;
        clk = 0;
        forever #10ns clk = !clk;
    end

    // Reset PC after every test stage
    int random_jump_address;
    int counting_reference;
    initial begin
        reset();
        assert (if_stage_bus.address == 0) else $fatal(4, "Unable to reset PC's address.");

        // Normal counting stage
        wb_stage_bus.pc_src = PCSRC_NEXT_ADDRESS;
        counting_reference = 0;
        repeat (TEST_SIZE_PER_STAGE) begin
            assert (counting_reference == if_stage_bus.address) else $fatal(1, "Mismatch between expected address and PC's address in counting stage. Expected: %h, Got: %h.", counting_reference, if_stage_bus.address);
            counting_reference = counting_reference + 4;
            @(negedge clk);
        end
        reset();
        assert (if_stage_bus.address == 0) else $fatal(4, "Unable to reset PC's address.");
        $display("PASSED normal counting stage.");

        // Jump address stage
        wb_stage_bus.pc_src = PCSRC_JUMP_ADDRESS;
        repeat (TEST_SIZE_PER_STAGE) begin
            assert (std::randomize(random_jump_address)) else $fatal(5, "Unable to randomize new jump address value.");
            wb_stage_bus.alu_result = random_jump_address;
            @(negedge clk);
            assert (random_jump_address == if_stage_bus.address) else $fatal(2, "Mismatch between PC's address and the random jump address in jump address stage. Expected: %h, Got: %h.", random_jump_address, if_stage_bus.address);
        end
        reset();
        assert (if_stage_bus.address == 0) else $fatal(4, "Unable to reset PC's address.");
        $display("PASSED jump address stage.");

        // JALR Jump address stage
        wb_stage_bus.pc_src = PCSRC_JUMP_JALR_ADDRESS;
        repeat (TEST_SIZE_PER_STAGE) begin
            assert (std::randomize(random_jump_address)) else $fatal(5, "Unable to randomize new jump address value.");
            wb_stage_bus.alu_result = random_jump_address;
            @(negedge clk);
            assert ({random_jump_address[31:1], 1'b0} == if_stage_bus.address) else $fatal(3, "Mismatch between PC's address and the JALR random jump address in JALR jump address stage. Expected: %b, Got: %b.", {random_jump_address[31:1], 1'b0}, if_stage_bus.address);
        end
        reset();
        assert (if_stage_bus.address == 0) else $fatal(4, "Unable to reset PC's address.");
        $display("PASSED JALR jump address stage.");

        $display("PASSED all test.");
        $finish;
    end
endprogram

module PC_tb;
    logic clk;
    logic rst_n;

    FetchStageBus if_stage_bus(
        .clk(clk),
        .rst_n(rst_n)
    );
    WritebackStageBus wb_stage_bus(
        .clk(clk),
        .rst_n(rst_n)
    );

    PC dut (
        .if_stage_bus(if_stage_bus),
        .wb_stage_bus(wb_stage_bus)
    );
    PCTbProgram #(
        .TEST_SIZE_PER_STAGE(2**8)
    ) test_env (
        .wb_stage_bus(wb_stage_bus),
        .if_stage_bus(if_stage_bus),
        .clk(clk),
        .rst_n(rst_n)
    );
endmodule