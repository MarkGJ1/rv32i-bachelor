/*
    File name: ALU.sv
    Description: This file contains the module for the ALU.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

module alu_unit (
    input wire [5:0] alu_op_i,
    input wire [DATA_WIDTH - 1:0] a_i,
    input wire [DATA_WIDTH - 1:0] b_i,
    output logic [DATA_WIDTH - 1:0] c_o
);

    always_comb begin
        unique case (alu_op_i)
            OP_ALU_ADD:  c_o = a_i + b_i;             
            OP_ALU_SUB:  c_o = a_i - b_i;
            OP_ALU_AND:  c_o = a_i & b_i;
            OP_ALU_OR:   c_o = a_i | b_i;
            OP_ALU_XOR:  c_o = a_i ^ b_i;
            OP_ALU_SLT:  c_o = ($signed(a_i) < $signed(b_i)) ? 1 : 0;
            OP_ALU_SLTU: c_o = (a_i < b_i) ? 1 : 0;
            OP_ALU_SLL:  c_o = a_i << b_i[4:0];
            OP_ALU_SRL:  c_o = a_i >> b_i[4:0];
            OP_ALU_SRA:  c_o = $signed(a_i) >>> b_i[4:0];
            default:      c_o = 'x; // Helps catch errors in simulation
        endcase
    end

endmodule