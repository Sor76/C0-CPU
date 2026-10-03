`timescale 1ns/1ps

program RegisterFileTbProgram (
    output logic clk,
    output logic rst_n,

    DecodeStageBus.master id_stage_bus_master,
    DecodeStageBus.slave id_stage_bus_slave,
    WritebackStageBus.master wb_stage_bus
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

    initial begin
        // Writing section
        wb_stage_bus.rd_write = RD_WRITE;
        for (int i = 0; i < 32; i = i + 1) begin
            wb_stage_bus.rd_write_data = i;
            wb_stage_bus.rd_address = i;
            @(posedge clk);
        end
        wb_stage_bus.rd_write = NO_RD_WRITE;
        $display("Finished writing section.");

        // Reading section
        for (int i = 0; i < 16; i = i + 1) begin
            id_stage_bus_master.rs1_address = i * 2;
            id_stage_bus_master.rs2_address = i * 2 + 1;
            @(posedge clk);
            assert (
                id_stage_bus_slave.rs1_data == id_stage_bus_master.rs1_address &&
                id_stage_bus_slave.rs2_data == id_stage_bus_master.rs2_address
            ) else $fatal(1, "Register File failed to record its value with its address.");
        end
        $display("Finished reading section.");

        // Read/Write address collision section
        wb_stage_bus.rd_write = RD_WRITE;
        wb_stage_bus.rd_write_data = 33;
        for (int i = 1; i < 32; i = i + 1) begin
            wb_stage_bus.rd_address = i;
            id_stage_bus_master.rs1_address = i;
            id_stage_bus_master.rs2_address = i;
            @(posedge clk);
            assert (
                id_stage_bus_slave.rs1_data == 33 &&
                id_stage_bus_slave.rs2_data == 33
            ) else $fatal(2, "Register File failed to pass the write data to read port when read and write address collided.");
        end
        wb_stage_bus.rd_write = NO_RD_WRITE;
        $display("Finished Read/Write address collision section.");

        // Resetting section
        reset();
        @(posedge clk);
        for (int i = 0; i < 16; i = i + 1) begin
            id_stage_bus_master.rs1_address = i * 2;
            id_stage_bus_master.rs2_address = i * 2 + 1;
            @(posedge clk);
            assert (
                id_stage_bus_slave.rs1_data == 0 && 
                id_stage_bus_slave.rs2_data == 0
            ) else $fatal(3, "Register File failed to cleared its register value(s).");
        end
        $display("Finished resetting Register File section.");

        $finish;
    end
endprogram

module RegisterFile_tb;
    logic clk;
    logic rst_n;

    DecodeStageBus id_stage_bus(
        .clk(clk),
        .rst_n(rst_n)
    );
    WritebackStageBus wb_stage_bus(
        .clk(clk),
        .rst_n(rst_n)
    );

    RegisterFile dut (
        .id_stage_bus(id_stage_bus.master),
        .wb_stage_bus(wb_stage_bus.slave)
    );
    RegisterFileTbProgram test_env (
        .clk(clk),
        .rst_n(rst_n),
        .id_stage_bus_master(id_stage_bus.master),
        .id_stage_bus_slave(id_stage_bus.slave),
        .wb_stage_bus(wb_stage_bus.master)
    );
endmodule