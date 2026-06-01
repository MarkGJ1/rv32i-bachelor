/*
    File name: tap_IR.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 29.04.2025
*/

`timescale 1ns/10ps

import tap_pkg::*;

module tap_instruction_register (
    input logic tck_i,
    input logic tdi_i,
    input logic trst_i,
    input logic shiftIR_i,
    input logic updateIR_i,
    output logic [INSTRUCTION_WIDTH-1:0] instruction_o // 4-bit instruction register
);

    logic [INSTRUCTION_WIDTH-1:0] ir_s; // TODO: MISSING INSTRUCTION WIDTH.

    always_ff @(posedge tck_i or negedge trst_i) begin
        if (!trst_i)
            ir_s <= '1; // IR needs to hold BYPASS instruction on RESET.
        else if (shiftIR_i) begin
            ir_s <= {tdi_i, ir_s[3:1]}; // Shift in instruction
        end
    end

    assign tdo_o = ir_s[0]; // Output least significant bit during shifting

    always_ff @(negedge tck_i) begin
        if (updateIR_i) begin
            instruction_o <= ir_s; // Update instruction register
        end
    end

endmodule
