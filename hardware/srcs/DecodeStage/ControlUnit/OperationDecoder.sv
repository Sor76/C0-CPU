`timescale 1ns/1ps

module OperationDecoder
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    DecodeStageBus.master id_stage_bus
);
    logic funct7_bit;
    logic special_imm_bit;
    assign funct7_bit = id_stage_bus.funct7[5];
    assign special_imm_bit = id_stage_bus.raw_imm[5];

    always_comb begin
        case (id_stage_bus.opcode)
            7'b0110011: begin
                // R-type Arithmetic and Logic
                id_stage_bus.alu_operand = 2'b00;
                id_stage_bus.alu_op      = ALUOp'({funct7_bit, id_stage_bus.funct3});
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = NO_JUMP;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            7'b0010011: begin
                // I-type Arithmetic and Logic
                id_stage_bus.alu_operand = 2'b10;
                case (id_stage_bus.funct3)
                    3'b101: id_stage_bus.alu_op = ALUOp'({special_imm_bit, id_stage_bus.funct3});
                    default: id_stage_bus.alu_op = ALUOp'(4'(id_stage_bus.funct3));
                endcase
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = NO_JUMP;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            7'b0000011: begin
                // Load
                id_stage_bus.alu_operand = 2'b10;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = NO_JUMP;
                id_stage_bus.read_op     = ReadOp'(id_stage_bus.funct3);
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_DEVICE_READ_DATA;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            7'b0100011: begin
                // Store
                id_stage_bus.alu_operand = 2'b10;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = NO_JUMP;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = WriteOp'(id_stage_bus.funct3[1:0]);
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = NO_RD_WRITE;
            end
            7'b1100011: begin
                // Branch
                id_stage_bus.alu_operand = 2'b11;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = ComOp'(id_stage_bus.funct3);
                id_stage_bus.jmp_op      = BRANCH;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = NO_RD_WRITE;
            end
            7'b1101111: begin
                // JAL
                id_stage_bus.alu_operand = 2'b11;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = JAL;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_NEXT_ADDRESS;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            7'b1100111: begin
                // JALR
                id_stage_bus.alu_operand = 2'b10;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = JALR;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_NEXT_ADDRESS;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            7'b0110111: begin
                // LUI
                id_stage_bus.alu_operand = 2'b10;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = NO_JUMP;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            7'b0010111: begin
                // AUIPC
                id_stage_bus.alu_operand = 2'b11;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = NO_JUMP;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = RD_WRITE;
            end
            default: begin
                // Default to NOP operation (addi zero, zero, 0)
                id_stage_bus.alu_operand = 2'b00;
                id_stage_bus.alu_op      = ADD;
                id_stage_bus.com_op      = EQ;
                id_stage_bus.jmp_op      = 2'b00;
                id_stage_bus.read_op     = NO_READ_OP;
                id_stage_bus.write_op    = NO_WRITE_OP;
                id_stage_bus.rd_src      = RDSRC_ALU_RESULT;
                id_stage_bus.rd_write    = NO_RD_WRITE;
            end
        endcase
    end
    
endmodule