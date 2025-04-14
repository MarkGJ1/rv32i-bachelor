/*
    File name: branch_unit.sv
    Description: This file contains the testbench for the branch unit.
    Author: Marko Gjorgjievski
    Date created: 15.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module branch_unit_tb;

    logic clk;
    logic branch_i = 1'b0;
    logic [2:0] branch_op_i = 3'b000;
    logic [DATA_WIDTH-1:0] a_i = 32'h00000000;
    logic [DATA_WIDTH-1:0] b_i = 32'h00000000;
    logic take_o;

    // Device Under Test (DUT)
    branch_unit dut (
        .branch_i(branch_i),
        .branch_op_i(branch_op_i),
        .a_i(a_i),
        .b_i(b_i),
        .take_o(take_o)
    );

    // Clock reset.
    initial clk = 1'b0;
    // Clock generation.
    always #18.52 clk = ~clk;

    initial begin
        // Test 1: BEQ (Branch Equal)
        a_i = 32'h00000000;
        b_i = 32'h00000000;
        branch_i = 1'b1;
        branch_op_i = BRANCH_BEQ;
        #37.04;
        assert(take_o == 1'b1) else $fatal(1,"Assertion failed: take_o != 1'b1 at time %0t", $time);

        // Test 2: BNE (Branch Not Equal)
        branch_op_i = BRANCH_BNE;
        #37.04;
        assert(take_o == 1'b0) else $fatal(1,"Assertion failed: take_o != 1'b0 at time %0t", $time);

        // Test 3: BNE with unequal values
        a_i = 32'h00000000;
        b_i = 32'h00000001;
        #37.04;
        assert(take_o == 1'b1) else $fatal(1,"Assertion failed: take_o != 1'b1 at time %0t", $time);

        // Test 4: BLT (Branch Less Than)
        a_i = 32'h11111111; // -1
        b_i = 32'h11111110; // -2
        branch_op_i = BRANCH_BLT;
        #37.04;
        assert(take_o == 1'b0) else $fatal(1,"Assertion failed: take_o != 1'b0 at time %0t", $time);

        // Test 5: BGE (Branch Greater Than or Equal)
        branch_op_i = BRANCH_BGE;
        #37.04;
        assert(take_o == 1'b1) else $fatal(1,"Assertion failed: take_o != 1'b1 at time %0t", $time);

        // Test 6: BLTU (Branch Less Than Unsigned)
        branch_op_i = BRANCH_BLTU;
        #37.04;
        assert(take_o == 1'b0) else $fatal(1,"Assertion failed: take_o != 1'b0 at time %0t", $time);

        // Test 7: BGEU (Branch Greater Than or Equal Unsigned)
        branch_op_i = BRANCH_BGEU;
        #37.04;
        assert(take_o == 1'b1) else $fatal(1,"Assertion failed: take_o != 1'b1 at time %0t", $time);

        // Test 8: JAL/JALR (Always branch)
        branch_op_i = BRANCH_JAL_JALR;
        #37.04;
        assert(take_o == 1'b1) else $fatal(1,"Assertion failed: take_o != 1'b1 at time %0t", $time);

        // Test 9: JAL/JALR with no branch
        branch_i = 1'b0;
        #37.04;
        assert(take_o == 1'b0) else $fatal(1,"Assertion failed: take_o != 1'b0 at time %0t", $time);

        $finish;
    end

    // Display outputs during simulation
    always @(posedge clk) begin
        $display("time %2t, branch_i = %b, branch_op_i = %3b, a_i = %8h, b_i = %8h, take_o = %b", 
                 $time, branch_i, branch_op_i, a_i, b_i, take_o);
    end 

    // VCD dump for waveform generation
    initial begin
        $dumpfile("../../../../../../sim/branch_unit.vcd");
        $dumpvars;
    end

endmodule
