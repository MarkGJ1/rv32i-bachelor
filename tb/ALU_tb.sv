/*
    File name: ALU_tb.sv
    Description: This file contains the testbench for the ALU.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module alu_tb;

    logic clk;
    logic [5:0] alu_op_i = 6'b000000;
    logic [DATA_WIDTH - 1:0] a_i = 32'h00000000;
    logic [DATA_WIDTH - 1:0] b_i = 32'h00000000;
    wire [DATA_WIDTH - 1:0] c_o;

    alu dut (
        .alu_op_i(alu_op_i),
        .a_i(a_i),
        .b_i(b_i),
        .c_o(c_o)
    );

    // Clock reset.
    initial clk = 1'b0;
    // Matching Tang Nano 9K crystal frequency.
    always #18.52 clk = ~clk;
    // ALU doesn't use clock, only used for debugging here.

    initial begin
        $display("Starting ALU Testbench...");

        // ADD
        a_i = 32'h0000_0001; b_i = 32'h0000_0001; alu_op_i = `OP_ALU_ADD;
        #37.04 assert(c_o == 32'h0000_0002) else $fatal("Assertion failed ADD: c_o != 0000_0002 at time %0t", $time);

        // SUB
        a_i = 32'h0000_0001; b_i = 32'h0000_0001; alu_op_i = `OP_ALU_SUB;
        #37.04 assert(c_o == 32'h0000_0000) else $fatal("Assertion failed SUB: c_o != 0000_0000 at time %0t", $time);

        // AND
        a_i = 32'h0000_0101; b_i = 32'h0001_0001; alu_op_i = `OP_ALU_AND;
        #37.04 assert(c_o == 32'h0000_0001) else $fatal("Assertion failed AND: c_o != 0000_0001 at time %0t", $time);

        // OR
        a_i = 32'h0000_0101; b_i = 32'h0001_0001; alu_op_i = `OP_ALU_OR;
        #37.04 assert(c_o == 32'h0001_0101) else $fatal("Assertion failed OR: c_o != 0001_0101 at time %0t", $time);

        // XOR
        a_i = 32'h0000_0101; b_i = 32'h0001_0001; alu_op_i = `OP_ALU_XOR;
        #37.04 assert(c_o == 32'h0001_0100) else $fatal("Assertion failed XOR: c_o != 0001_0100 at time %0t", $time);

        // SLT (Signed)
        a_i = 32'hFFFF_FFF0; b_i = 32'h0000_0010; alu_op_i = `OP_ALU_SLT;
        #37.04 assert(c_o == 32'h0000_0001) else $fatal("Assertion failed SLT: c_o != 0000_0001 at time %0t", $time); // -16 < 16 → 1

        // SLTU (Unsigned)
        a_i = 32'h0000_0010; b_i = 32'hFFFF_FFF0; alu_op_i = `OP_ALU_SLTU;
        #37.04 assert(c_o == 32'h0000_0001) else $fatal("Assertion failed SLTU: c_o != 0000_0001 at time %0t", $time); // 16 < large unsigned → 1

        // SLL (Logical Shift Left)
        a_i = 32'h0000_0001; b_i = 32'h0000_0004; alu_op_i = `OP_ALU_SLL;
        #37.04 assert(c_o == 32'h0000_0010) else $fatal("Assertion failed SLL: c_o != 0000_0010 at time %0t", $time);

        // SRL (Logical Shift Right)
        a_i = 32'h0000_0100; b_i = 32'h0000_0001; alu_op_i = `OP_ALU_SRL;
        #37.04 assert(c_o == 32'h0000_0080) else $fatal("Assertion failed SRL: c_o != 0000_0080 at time %0t", $time);

        // SRA (Arithmetic Shift Right)
        a_i = 32'hFFFF_F000; b_i = 32'h0000_0004; alu_op_i = `OP_ALU_SRA;
        #37.04 assert(c_o == 32'hFFFF_FF00) else $fatal("Assertion failed SRA: c_o != FFFF_FF00 at time %0t", $time); // Sign bit extended

        // SRA with Large Shift
        a_i = 32'h8000_0000; b_i = 32'h0000_001F; alu_op_i = `OP_ALU_SRA;
        #37.04 assert(c_o == 32'hFFFF_FFFF) else $fatal("Assertion failed SRA LS: c_o != FFFF_FFFF at time %0t", $time); // Sign bit replicated

        $display("All ALU Tests Passed!");
        $finish;
    end

    always @(posedge clk) begin 
        $display("time %2t, alu_op_i = %b, a_i = %h, b_i = %h, c_o = %h", 
        $time, alu_op_i, a_i, b_i, c_o);
    end 

    initial begin
        $dumpfile("../../../../../../sim/alu.vcd");
        $dumpvars;
    end

endmodule
