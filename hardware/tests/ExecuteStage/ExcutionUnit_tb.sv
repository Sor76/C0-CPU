`timescale 1ns/1ps

program ExecutionunitTbProgram #(
    parameter int TEST_SIZE_PER_STAGE = 2 ** 24
) (
    DecodeStageBus.master id_stage_bus,
    ExecuteStageBus.slave ex_stage_bus
);
    logic [31:0] operand_1;
    logic [31:0] operand_2;
    logic [31:0] target_alu_result;
    PCSrc target_pc_src;

    initial begin
        // Pure Math and Logic verification (R/I-type arithmetic and logic)
        id_stage_bus.com_op = EQ;
        id_stage_bus.jmp_op = NO_JUMP;
        repeat (TEST_SIZE_PER_STAGE) begin
            // Input randomization
            assert (std::randomize(id_stage_bus.extended_imm) &&
                    std::randomize(id_stage_bus.rs2_data) &&
                    std::randomize(id_stage_bus.rs1_data) &&
                    std::randomize(id_stage_bus.alu_operand) with {id_stage_bus.alu_operand inside {2'b00, 2'b10};} &&
                    std::randomize(id_stage_bus.alu_op)
            ) else $fatal(5, "Unable to randomize new value(s).");

            // ALU operand setup
            operand_1 = id_stage_bus.rs1_data;
            case (id_stage_bus.alu_operand[1])
                1'b0: operand_2 = id_stage_bus.rs2_data;
                1'b1: operand_2 = id_stage_bus.extended_imm;
            endcase

            // Expected ALU's result
            case (id_stage_bus.alu_op)
                ADD:    target_alu_result = operand_1 + operand_2;
                SUB:    target_alu_result = operand_1 - operand_2;
                SLL:    target_alu_result = operand_1 << operand_2;
                SLT:    target_alu_result = $signed(operand_1) < $signed(operand_2);
                SLTU:   target_alu_result = $unsigned(operand_1) < $unsigned(operand_2);
                XOR:    target_alu_result = operand_1 ^ operand_2;
                SRL:    target_alu_result = operand_1 >> operand_2;
                SRA:    target_alu_result = operand_1 >>> operand_2;
                OR:     target_alu_result = operand_1 | operand_2;
                AND:    target_alu_result = operand_1 & operand_2;
            endcase
            #1ns;
            assert (target_alu_result == ex_stage_bus.alu_result) else $fatal(1, "Mismatch value between target ALU result and its actual output.");
        end
        $display("Finished testing ALU normal math operation.");


        // +4 Verification
        repeat (TEST_SIZE_PER_STAGE) begin
            assert (std::randomize(id_stage_bus.current_address)) else $fatal(5, "Unable to randomize new value(s).");
            #1ns;
            assert (ex_stage_bus.next_address == id_stage_bus.current_address + 4) else $fatal(2, "Mismatch value between +4 unit's output and it testbench's computed value.");
        end
        $display("Finished testing +4 unit.");


        // Jumping Verification (both conditional and unconditional)
        id_stage_bus.alu_op = ADD;
        repeat (TEST_SIZE_PER_STAGE) begin
            // Input randomization
            assert (std::randomize(id_stage_bus.extended_imm) &&
                    std::randomize(id_stage_bus.rs2_data) &&
                    std::randomize(id_stage_bus.current_address) &&
                    std::randomize(id_stage_bus.rs1_data) &&
                    std::randomize(id_stage_bus.com_op) &&
                    std::randomize(id_stage_bus.jmp_op) with {id_stage_bus.jmp_op != NO_JUMP;}
            ) else $fatal(5, "Unable to randomize new value(s).");

            // Expected PCSrc
            case (id_stage_bus.jmp_op)
                BRANCH: begin
                    case (id_stage_bus.com_op)
                        EQ:     target_pc_src = PCSrc'(id_stage_bus.rs1_data == id_stage_bus.rs2_data);
                        NE:     target_pc_src = PCSrc'(id_stage_bus.rs1_data != id_stage_bus.rs2_data);
                        LT:     target_pc_src = PCSrc'($signed(id_stage_bus.rs1_data) < $signed(id_stage_bus.rs2_data));
                        GE:     target_pc_src = PCSrc'($signed(id_stage_bus.rs1_data) > $signed(id_stage_bus.rs2_data));
                        LTU:    target_pc_src = PCSrc'($unsigned(id_stage_bus.rs1_data) < $unsigned(id_stage_bus.rs2_data));
                        GEU:    target_pc_src = PCSrc'($unsigned(id_stage_bus.rs1_data) > $unsigned(id_stage_bus.rs2_data));
                    endcase
                    id_stage_bus.alu_operand = 2'b11;
                end
                JAL: begin
                    id_stage_bus.alu_operand = 2'b11;
                    target_pc_src = PCSRC_JUMP_ADDRESS;
                end
                JALR: begin
                    id_stage_bus.alu_operand = 2'b10;
                    target_pc_src = PCSRC_JUMP_JALR_ADDRESS;
                end
            endcase

            // Operand setup
            operand_2 = id_stage_bus.extended_imm;
            case (id_stage_bus.alu_operand[0])
                1'b0: operand_1 = id_stage_bus.rs1_data;
                1'b1: operand_1 = id_stage_bus.current_address;
            endcase

            // Expected target address
            target_alu_result = operand_1 + operand_2;

            #1ns;
            assert (target_pc_src == ex_stage_bus.pc_src) else $fatal(3, "Mismatch between expected PCSrc and the actual PCSrc.");
            assert (target_alu_result == ex_stage_bus.alu_result) else $fatal(4, "Mismatch between expected target address and the actual address.");
        end
        $display("Finished testing EU's take on jump operation (both unconditional and conditional).");

        $finish;
    end
endprogram

module ExecutionUnit_tb;
    ExecuteStageBus ex_stage_bus();
    DecodeStageBus id_stage_bus();

    ExecutionUnit dut (
        .ex_stage_bus(ex_stage_bus.master),
        .id_stage_bus(id_stage_bus.slave)
    );
    ExecutionunitTbProgram #(
        .TEST_SIZE_PER_STAGE(2**8)
    ) test_env (
        .id_stage_bus(id_stage_bus.master),
        .ex_stage_bus(ex_stage_bus.slave)
    );
endmodule