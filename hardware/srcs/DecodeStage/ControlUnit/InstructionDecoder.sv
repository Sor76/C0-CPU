`timescale 1ns/1ps

module InstructionDecoder
    import OtherSignals_pkg::*;
    import Types_pkg::*;
(
    input   Word            instruction,

    output  logic [19:0]    raw_imm,
    output  InstFormat      inst_format,
    output  RegAddr         rs1_addr,
    output  RegAddr         rs2_addr,
    output  RegAddr         rd_addr,
    output  logic [6:0]     opcode,
    output  logic [2:0]     funct3,
    output  logic [6:0]     funct7
);
    assign opcode = instruction[6:0]; 

    always_comb begin
        case (opcode)
            7'b0110011: begin
                // R-type
                raw_imm     = '0;
                inst_format = R_TYPE;
                rs1_addr    = RegAddr'(instruction[19:15]);
                rs2_addr    = RegAddr'(instruction[24:20]);
                rd_addr     = RegAddr'(instruction[11:7]);
                funct3      = instruction[14:12];
                funct7      = instruction[31:25];
            end
            7'b0010011, 7'b0000011, 7'b1100111: begin
                // I-type
                inst_format  = I_TYPE;
                rs1_addr     = RegAddr'(instruction[19:15]);
                rs2_addr     = RegAddr'('0);
                rd_addr      = RegAddr'(instruction[11:7]);
                funct3       = instruction[14:12];
                funct7       = '0;

                if (opcode == 7'b0010011 && funct3 inside {3'b001, 3'b101}) raw_imm = instruction[24:20];
                else raw_imm = instruction[31:20];
            end
            7'b0100011: begin
                // S-type
                raw_imm      = {instruction[31:25], instruction[11:7]};
                inst_format  = S_TYPE;
                rs1_addr     = RegAddr'(instruction[19:15]);
                rs2_addr     = RegAddr'(instruction[24:20]);
                rd_addr      = RegAddr'('0);
                funct3       = instruction[14:12];
                funct7       = '0;
            end
            7'b1100011: begin
                // B-type
                raw_imm      = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
                inst_format  = B_TYPE;
                rs1_addr     = RegAddr'(instruction[19:15]);
                rs2_addr     = RegAddr'(instruction[24:20]);
                rd_addr      = RegAddr'('0);
                funct3       = instruction[14:12];
                funct7       = '0;
            end
            7'b0110111, 7'b0010111: begin
                // U-type
                raw_imm      = instruction[31:12];
                inst_format  = U_TYPE;
                rs1_addr     = RegAddr'('0);
                rs2_addr     = RegAddr'('0);
                rd_addr      = RegAddr'(instruction[11:7]);
                funct3       = '0;
                funct7       = '0;
            end
            7'b1101111: begin
                // J-type
                raw_imm      = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
                inst_format  = J_TYPE;
                rs1_addr     = RegAddr'('0);
                rs2_addr     = RegAddr'('0);
                rd_addr      = RegAddr'(instruction[11:7]);
                funct3       = '0;
                funct7       = '0;
            end
            default: begin
                // Default to NOP operation (addi zero, zero, 0).
                // Need a bit of help from Operation Decoder in default statement
                raw_imm      = '0;
                inst_format  = I_TYPE;
                rs1_addr     = RegAddr'('0);
                rs2_addr     = RegAddr'('0);
                rd_addr      = RegAddr'('0);
                funct3       = '0;
                funct7       = '0;
            end
        endcase
    end
    
endmodule