/*
    File name: ALU.sv
    Description: This file contains the module for the ALU.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

`define OP_ALU_NOP    6'b000000 
`define OP_ALU_ADD    6'b011001 // Add
`define OP_ALU_SUB    6'b011011 // Subtract
`define OP_ALU_AND    6'b011101 // Bitwise AND
`define OP_ALU_OR     6'b011111 // Bitwise OR
`define OP_ALU_XOR    6'b100001 // Bitwise XOR
`define OP_ALU_SLT    6'b100011 // Set Less Than (signed)
`define OP_ALU_SLTU   6'b100101 // Set Less Than (unsigned)
`define OP_ALU_SLL    6'b100111 // Shift Left Logical
`define OP_ALU_SRL    6'b101001 // Shift Right Logical
`define OP_ALU_SRA    6'b101011 // Shift Right Arithmetic

module alu (
    input wire [5:0] alu_op_i,
    input wire [DATA_WIDTH - 1:0] a_i,
    input wire [DATA_WIDTH - 1:0] b_i,
    output logic [DATA_WIDTH - 1:0] c_o
);

    always @(*) begin
        unique case (alu_op_i)
            `OP_ALU_ADD:  c_o = a_i + b_i;             
            `OP_ALU_SUB:  c_o = a_i - b_i;
            `OP_ALU_AND:  c_o = a_i & b_i;
            `OP_ALU_OR:   c_o = a_i | b_i;
            `OP_ALU_XOR:  c_o = a_i ^ b_i;
            `OP_ALU_SLT:  c_o = ($signed(a_i) < $signed(b_i)) ? 1 : 0;
            `OP_ALU_SLTU: c_o = (a_i < b_i) ? 1 : 0;
            `OP_ALU_SLL:  c_o = a_i << b_i[4:0];
            `OP_ALU_SRL:  c_o = a_i >> b_i[4:0];
            `OP_ALU_SRA:  c_o = $signed(a_i) >>> b_i[4:0];
            default:      c_o = 'x; // Helps catch errors in simulation
        endcase
    end

endmodule