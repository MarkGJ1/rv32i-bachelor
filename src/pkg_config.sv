/*
    File name: pkg_config.sv
    Description: Package used for constant values.
    Author: Marko Gjorgjievski
    Date created: 13.01.2025
    Date modified: 14.04.2025
*/

package pkg_config;

    // General configuration constants
    localparam int DATA_WIDTH = 32;
    localparam int NUM_REGISTER = 32;
    localparam int INST_WIDTH = 32;
    
    // ALU operation codes
    localparam bit [5:0] OP_ALU_NOP  = 6'b000000; 
    localparam bit [5:0] OP_ALU_ADD  = 6'b011001; // Add
    localparam bit [5:0] OP_ALU_SUB  = 6'b011011; // Subtract
    localparam bit [5:0] OP_ALU_AND  = 6'b011101; // Bitwise AND
    localparam bit [5:0] OP_ALU_OR   = 6'b011111; // Bitwise OR
    localparam bit [5:0] OP_ALU_XOR  = 6'b100001; // Bitwise XOR
    localparam bit [5:0] OP_ALU_SLT  = 6'b100011; // Set Less Than (signed)
    localparam bit [5:0] OP_ALU_SLTU = 6'b100101; // Set Less Than (unsigned)
    localparam bit [5:0] OP_ALU_SLL  = 6'b100111; // Shift Left Logical
    localparam bit [5:0] OP_ALU_SRL  = 6'b101001; // Shift Right Logical
    localparam bit [5:0] OP_ALU_SRA  = 6'b101011; // Shift Right Arithmetic

    // Branch operation codes
    localparam bit [2:0] BRANCH_BEQ      = 3'b000; // Branch Equal
    localparam bit [2:0] BRANCH_BNE      = 3'b001; // Branch Not Equal
    localparam bit [2:0] BRANCH_BLT      = 3'b100; // Branch Less Than
    localparam bit [2:0] BRANCH_BGE      = 3'b101; // Branch Greater Than Or Equal
    localparam bit [2:0] BRANCH_BLTU     = 3'b110; // Branch Less Than Unsigned
    localparam bit [2:0] BRANCH_BGEU     = 3'b111; // Branch Greater Than Or Equal Unsigned
    localparam bit [2:0] BRANCH_JAL_JALR = 3'b010; // Jump in case of JAL or JALR instruction

    // Instruction operation codes
    localparam int       OPCODE     = 7;
    localparam bit [6:0] OP_LUI     = 7'b0110111; // Load Upper Immediate
    localparam bit [6:0] OP_AUIPC   = 7'b0010111; // Add Upper Immediate to PC
    localparam bit [6:0] OP_JAL     = 7'b1101111; // Jump and Link
    localparam bit [6:0] OP_JALR    = 7'b1100111; // Jump and Link Register
    localparam bit [6:0] OP_BRANCH  = 7'b1100011; // Branch Instructions (BEQ, BNE, BLT, etc.)
    localparam bit [6:0] OP_LOAD    = 7'b0000011; // Load Instructions (LB, LH, LW, LBU, LHU)
    localparam bit [6:0] OP_STORE   = 7'b0100011; // Store Instructions (SB, SH, SW)
    localparam bit [6:0] OP_ALU     = 7'b0110011; // ALU Instructions (ADD, SUB, AND, OR, XOR, etc.)
    localparam bit [6:0] OP_ALUI    = 7'b0010011; // ALU Immediate Instructions (ADDI, ANDI, ORI, XORI, etc.)
    localparam bit [6:0] OP_FENCE   = 7'b0001111; // Fence
    localparam bit [6:0] OP_SYSTEM  = 7'b1110011; // System Instructions (ECALL, EBREAK, etc.)

    // Miscellaneous constants
    localparam int FUNCT_7 = 7;

endpackage
