`timescale 1ns/1ps

module RegisterFile
    import ControlSignals_pkg::*;
(
    DecodeStageBus.master id_stage_bus,
    WritebackStageBus.slave wb_stage_bus
);
    logic [31:0] register_array [31:0] = '{default: 0};

    // Helper functions
    function bit rd_write_check;
        return wb_stage_bus.rd_write == RD_WRITE && wb_stage_bus.rd_address != 5'b00000;
    endfunction
    function bit address_collide (input logic [31:0] read_address);
        return rd_write_check() && wb_stage_bus.rd_address == read_address;
    endfunction

    // rd writing logic / reset
    always_ff @(posedge id_stage_bus.clk or negedge id_stage_bus.rst_n) begin
        if (!id_stage_bus.rst_n) begin
            register_array <= '{default: 0};
        end else if (rd_write_check()) begin
            register_array[wb_stage_bus.rd_address] <= wb_stage_bus.rd_write_data;
        end
    end

    // rs reading logic
    always_ff @(posedge id_stage_bus.clk) begin
        id_stage_bus.rs1_data <= address_collide(id_stage_bus.rs1_address) ? wb_stage_bus.rd_write_data : register_array[id_stage_bus.rs1_address];
        id_stage_bus.rs2_data <= address_collide(id_stage_bus.rs2_address) ? wb_stage_bus.rd_write_data : register_array[id_stage_bus.rs2_address];
    end
endmodule