`timescale 1ns/1ps

program ImmediateAssemblerTbProgram #(
    parameter int TEST_SIZE = 2 ** 24
) (
    DecodeStageBus.master id_stage_bus_master,
    DecodeStageBus.slave id_stage_bus_slave

);
    logic [31:0] target_value;
    initial begin
        repeat(TEST_SIZE) begin
            assert (std::randomize(id_stage_bus_master.instruction_format) with {id_stage_bus_master.instruction_format != R_TYPE;}) else $fatal(2, "Unable to randomize new format type.");
            
            // Randomizing raw imm
            case (id_stage_bus_master.instruction_format)
                I_TYPE, S_TYPE, B_TYPE: begin
                    if (!std::randomize(id_stage_bus_master.raw_imm) with {id_stage_bus_master.raw_imm inside {[-(2**12):2**12-1]};}) $fatal(3, "Unable to randomize new target value.");
                end
                U_TYPE, J_TYPE: begin
                    if (!std::randomize(id_stage_bus_master.raw_imm)) $fatal(3, "Unable to randomize new target value.");
                end
            endcase

            // Expected extended imm
            case (id_stage_bus_master.instruction_format)
                I_TYPE, S_TYPE: begin
                    target_value = $signed(id_stage_bus_master.raw_imm[11:0]);
                end 
                B_TYPE: begin
                    target_value = $signed({id_stage_bus_master.raw_imm[11:0], 1'b0});
                end
                U_TYPE: begin
                    target_value = {id_stage_bus_master.raw_imm, 12'b0};
                end
                J_TYPE: begin
                    target_value = $signed({id_stage_bus_master.raw_imm, 1'b0});
                end
            endcase

            #1ns;
            assert (id_stage_bus_master.extended_imm == target_value) else $fatal(1, "Mismatch value between extended immediate value (%0d) and its target value(%0d).", id_stage_bus_master.extended_imm, target_value);
        end
        $finish;
    end
endprogram

module ImmediateAssembler_tb;
    DecodeStageBus id_stage_bus ();

    ImmediateAssembler dut (
        .id_stage_bus(id_stage_bus)
    );
    ImmediateAssemblerTbProgram #(
        .TEST_SIZE(2**16)
    ) test_env (
        .id_stage_bus_master(id_stage_bus.master),
        .id_stage_bus_slave(id_stage_bus.slave)
    );
endmodule