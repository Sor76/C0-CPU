`timescale 1ns/1ps

module InstructionDecoder
    import OtherSignals_pkg::*;
(
    DecodeStageBus.master id_stage_bus,
    FetchStageBus.slave if_stage_bus
);
    assign id_stage_bus.opcode = if_stage_bus.instruction[6:0];
    always_comb begin
        case (id_stage_bus.opcode)
            7'b0110011: begin
                // R-type
                id_stage_bus.raw_imm = 0;
                id_stage_bus.instruction_format = R_TYPE;

                id_stage_bus.rs1_address = if_stage_bus.instruction[19:15];
                id_stage_bus.rs2_address = if_stage_bus.instruction[24:20];
                id_stage_bus.rd_address = if_stage_bus.instruction[11:7];
                
                id_stage_bus.funct3 = if_stage_bus.instruction[14:12];
                id_stage_bus.funct7 = if_stage_bus.instruction[31:25];
            end
            7'b0010011, 7'b0000011, 7'b1100111: begin
                // I-type
                id_stage_bus.instruction_format = I_TYPE;

                id_stage_bus.rs1_address = if_stage_bus.instruction[19:15];
                id_stage_bus.rs2_address = 5'b00000;
                id_stage_bus.rd_address = if_stage_bus.instruction[11:7];
                
                id_stage_bus.funct3 = if_stage_bus.instruction[14:12];
                id_stage_bus.funct7 = 7'b0000000;

                if (id_stage_bus.opcode == 7'b0010011 && id_stage_bus.funct3 inside {3'b001, 3'b101}) id_stage_bus.raw_imm = 20'(if_stage_bus.instruction[24:20]);
                else id_stage_bus.raw_imm = 20'(if_stage_bus.instruction[31:20]);
            end
            7'b0100011: begin
                // S-type
                id_stage_bus.raw_imm = 20'({if_stage_bus.instruction[31:25], if_stage_bus.instruction[11:7]});
                id_stage_bus.instruction_format = S_TYPE;

                id_stage_bus.rs1_address = if_stage_bus.instruction[19:15];
                id_stage_bus.rs2_address = if_stage_bus.instruction[24:20];
                id_stage_bus.rd_address = 5'b00000;
                
                id_stage_bus.funct3 = if_stage_bus.instruction[14:12];
                id_stage_bus.funct7 = 7'b0000000;
            end
            7'b1100011: begin
                // B-type
                id_stage_bus.raw_imm = 20'({if_stage_bus.instruction[31], if_stage_bus.instruction[7], if_stage_bus.instruction[30:25], if_stage_bus.instruction[11:8]});
                id_stage_bus.instruction_format = B_TYPE;

                id_stage_bus.rs1_address = if_stage_bus.instruction[19:15];
                id_stage_bus.rs2_address = if_stage_bus.instruction[24:20];
                id_stage_bus.rd_address = 5'b00000;
                
                id_stage_bus.funct3 = if_stage_bus.instruction[14:12];
                id_stage_bus.funct7 = 7'b0000000;
            end
            7'b0110111, 7'b0010111: begin
                // U-type
                id_stage_bus.raw_imm = {if_stage_bus.instruction[31], if_stage_bus.instruction[19:12], if_stage_bus.instruction[20], if_stage_bus.instruction[30:21]};
                id_stage_bus.instruction_format = U_TYPE;

                id_stage_bus.rs1_address = 5'b00000;
                id_stage_bus.rs2_address = 5'b00000;
                id_stage_bus.rd_address = if_stage_bus.instruction[11:7];
                
                id_stage_bus.funct3 = 3'b000;
                id_stage_bus.funct7 = 7'b0000000;
            end
            7'b1101111: begin
                // J-type
                id_stage_bus.raw_imm = if_stage_bus.instruction[31:12];
                id_stage_bus.instruction_format = J_TYPE;

                id_stage_bus.rs1_address = 5'b00000;
                id_stage_bus.rs2_address = 5'b00000;
                id_stage_bus.rd_address = if_stage_bus.instruction[11:7];
                
                id_stage_bus.funct3 = 3'b000;
                id_stage_bus.funct7 = 7'b0000000;
            end
            default: begin
                // Default to NOP operation (addi zero, zero, 0).
                // Need a bit of help from Operation Decoder in default statement
                id_stage_bus.raw_imm = '0;
                id_stage_bus.instruction_format = I_TYPE;

                id_stage_bus.rs1_address = 5'b00000;
                id_stage_bus.rs2_address = 5'b00000;
                id_stage_bus.rd_address = 5'b00000;
                
                id_stage_bus.funct3 = 3'b000;
                id_stage_bus.funct7 = 7'b0000000;
            end
        endcase
    end
    
endmodule