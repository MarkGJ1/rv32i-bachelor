/*
    File name: instruction_decoder.sv
    Description: This file contains the module for the instruction decoder.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

module decoder (
    input wire [INST_WIDTH-1:0] inst_i,
    output wire [OPCODE-1:0] opcode_o,
    
    // Control Signals
    output logic branch_o,
    output logic [1:0] result_mux_o, // # alu= 2'b00, pc+4 = 2'b01, mem = 2'b10
    output logic [2:0] branch_op_o,
    output logic mem_write_o,
    output logic alu_src_a_o, // 0 = reg, 1 = pc
    output logic alu_src_b_o, // 0 = reg, 1 = imme
    output logic reg_write_o,
    output logic [5:0] alu_op_o,
    output wire [$clog2(NUM_REGISTER) - 1:0] rs1_addr_o,
    output wire [$clog2(NUM_REGISTER) - 1:0] rs2_addr_o,
    output wire [$clog2(NUM_REGISTER) - 1:0] rd_addr_o
);

    wire [OPCODE-1:0] opcode = inst_i[OPCODE-1:0];
    wire [FUNCT_7-1:0] funct_7 = inst_i[INST_WIDTH-1:INST_WIDTH - FUNCT_7];
    wire [2:0] funct_3 = inst_i[14:12];

    always_comb begin
        branch_o = 0;
        result_mux_o = 2'b00;
        alu_op_o = OP_ALU_ADD;
        branch_op_o = BRANCH_BEQ;
        mem_write_o = 0;
        alu_src_a_o = 0;
        alu_src_b_o = 0;
        reg_write_o = 0;
        
        case (opcode)
            OP_LUI: begin
                alu_src_b_o = 1;
                reg_write_o = 1;
            end
            OP_AUIPC: begin
                alu_src_a_o = 1;
                alu_src_b_o = 1;
                reg_write_o = 1;
            end
            OP_JAL: begin
                reg_write_o = 1;
                branch_o = 1;
                result_mux_o = 2'b01;
                alu_src_a_o = 1;
                alu_src_b_o = 1;
                branch_op_o = BRANCH_JAL_JALR;
            end
            OP_JALR: begin
                reg_write_o = 1;
                branch_o = 1;
                result_mux_o = 2'b01;
                alu_src_b_o = 1;
                branch_op_o = BRANCH_JAL_JALR;
            end
            OP_BRANCH: begin
                branch_o = 1;
                alu_src_a_o = 1;
                alu_src_b_o = 1;
                branch_op_o = funct_3 inside {
                    BRANCH_BEQ, BRANCH_BNE, BRANCH_BLT, BRANCH_BGE, BRANCH_BLTU, BRANCH_BGEU
                } ? funct_3 : BRANCH_BEQ;
            end
            OP_LOAD: begin
                reg_write_o = 1;
                result_mux_o = 2'b10;
                alu_src_b_o = 1;
            end
            OP_STORE: begin
                mem_write_o = 1;
                alu_src_b_o = 1;
            end
            OP_ALU: begin
                reg_write_o = 1;
                case (funct_3)
                    3'b000: alu_op_o = (inst_i[30]) ? OP_ALU_SUB : OP_ALU_ADD;
                    3'b111: alu_op_o = OP_ALU_AND;
                    3'b110: alu_op_o = OP_ALU_OR;
                    3'b100: alu_op_o = OP_ALU_XOR;
                    3'b010: alu_op_o = OP_ALU_SLT;
                    3'b011: alu_op_o = OP_ALU_SLTU;
                    3'b001: alu_op_o = OP_ALU_SLL;
                    3'b101: alu_op_o = (inst_i[30]) ? OP_ALU_SRA : OP_ALU_SRL;
                    default: alu_op_o = OP_ALU_NOP;
                endcase
            end
            OP_ALUI: begin
                alu_src_b_o = 1;
                reg_write_o = 1;
                case (funct_3)
                    3'b000: alu_op_o = OP_ALU_ADD;
                    3'b110: alu_op_o = OP_ALU_OR;
                    3'b111: alu_op_o = OP_ALU_AND;
                    3'b100: alu_op_o = OP_ALU_XOR;
                    3'b001: alu_op_o = OP_ALU_SLL;
                    3'b010: alu_op_o = OP_ALU_SLT;
                    3'b011: alu_op_o = OP_ALU_SLTU;
                    3'b101: alu_op_o = (inst_i[30]) ? OP_ALU_SRA : OP_ALU_SRL;
                    default: alu_op_o = OP_ALU_NOP; // Default case for safety
                endcase
            end
            OP_FENCE: begin
                // Implement fence instruction
            end
            OP_SYSTEM: begin
                // Implement ECALL, EBREAK, etc.
            end
            default: begin
                // Handle unrecognized opcodes
            end
        endcase
    end

    assign opcode_o = opcode;
    assign rd_addr_o = inst_i[11:7];
    assign rs1_addr_o = (opcode inside {OP_LUI}) ? 5'b00000 : inst_i[19:15];
    assign rs2_addr_o = inst_i[24:20];

endmodule