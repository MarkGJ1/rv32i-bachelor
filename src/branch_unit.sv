/*
    File name: branch_unit.sv
    Description: This file contains the module for the branch unit.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

`define BRANCH_BEQ      3'b000 // Branch Equal
`define BRANCH_BNE      3'b001 // Branch Not Equal
`define BRANCH_BLT      3'b100 // Branch Less Than
`define BRANCH_BGE      3'b101 // Branch Greater Than Or Equal
`define BRANCH_BLTU     3'b110 // Branch Less Than Unsigned
`define BRANCH_BGEU     3'b111 // Branch Greater Than Or Equal Unsigned
`define BRANCH_JAL_JALR 3'b010 // Jump in case of JAL or JALR instruction

module branch_unit (
    input wire branch_i,
    input wire [2:0] branch_op_i,
    input wire [DATA_WIDTH - 1:0] a_i,
    input wire [DATA_WIDTH - 1:0] b_i,
    output logic take_o
);

    always_comb begin
        take_o = 0;
        if (branch_i) begin
            case (branch_op_i)
                `BRANCH_BEQ:    take_o = (a_i == b_i);
                `BRANCH_BNE:    take_o = (a_i != b_i);
                `BRANCH_BLT:    take_o = ($signed(a_i) < $signed(b_i));
                `BRANCH_BGE:    take_o = ($signed(a_i) >= $signed(b_i));
                `BRANCH_BLTU:   take_o = (a_i < b_i);
                `BRANCH_BGEU:   take_o = (a_i >= b_i);
                `BRANCH_JAL_JALR: take_o = 1;
                default:        take_o = 0;
            endcase
        end
    end

endmodule
