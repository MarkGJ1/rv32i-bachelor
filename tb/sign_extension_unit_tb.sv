/*
    File name: sign_extension_unit_tb.sv
    Description: This file contains the testbench 
                for the sign extension unit.
    Author: Marko Gjorgjievski
    Date: 15.03.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module sign_extension_tb;

    logic clk;
    logic [INST_WIDTH - 1:0] inst = 32'h00000000;
    logic [OPCODE - 1:0] opcode = OP_ALUI;
    wire [DATA_WIDTH - 1:0] immediate_extended;

    sign_extension dut (
        .inst_i(inst),
        .opcode_i(opcode),    
        .immediate_extended_o(immediate_extended)
    );

    // Clock reset.
    initial clk = 1'b0;
    // Matching Tang Nano 9k crystal.
    always #20 clk = ~clk;
  
    initial begin
        // TODO: Verify frequency if cause of issue after TAP implementation.
        inst = 32'h80000000;
        opcode = OP_ALUI;
        #40; // Possible problems when simulating TANG NANO frequency.
        assert(immediate_extended == 32'hffff_f800) else $fatal(1,"Assertion failed: immediate != ffff_f800 at time %0t", $time);

        inst = 32'h10100000;
        opcode = OP_LOAD;
        #40;
        assert(immediate_extended == 32'h0000_0101) else $fatal(1,"Assertion failed: immediate != 0000_0101 at time %0t", $time);

        inst = 32'h80F80023;
        opcode = OP_STORE;
        #40;
        assert(immediate_extended == 32'hffff_f800) else $fatal(1,"Assertion failed: immediate != ffff_f800 at time %0t", $time);

        inst = 32'h00F80023;
        opcode = OP_STORE;
        #40;
        assert(immediate_extended == 32'h0000_0000) else $fatal(1,"Assertion failed: immediate != 0000_0000 at time %0t", $time);

        inst = 32'h000170b7;
        opcode = OP_LUI;
        #40;
        assert(immediate_extended == 32'h0001_7000) else $fatal(1,"Assertion failed: immediate != 0001_7000 at time %0t", $time);

        inst = 32'h000170b7;
        opcode = OP_AUIPC;
        #40;        
        assert(immediate_extended == 32'h0001_7000) else $fatal(1,"Assertion failed: immediate != 0001_7000 at time %0t", $time);        

        inst = 32'h0e80026f;
        opcode = OP_JAL;
        #40;
        assert(immediate_extended == 32'h0000_00e8) else $fatal(1,"Assertion failed: immediate != 0000_00e8 at time %0t", $time);
        
        inst = 32'hf19ff26f;
        opcode = OP_JAL;
        #40;
        assert(immediate_extended == 32'hffff_ff18) else $fatal(1,"Assertion failed: immediate != ffff_ff18 at time %0t", $time);

        inst = 32'h00c00167;
        opcode = OP_JALR;
        #40;
        assert(immediate_extended == 32'h0000_000c) else $fatal(1,"Assertion failed: immediate != 0000_000c at time %0t", $time);

        inst = 32'hfe4104e3;
        opcode = OP_BRANCH;
        #40;
        assert(immediate_extended == 32'hffff_ffe8) else $fatal(1,"Assertion failed: immediate != ffff_ffe8 at time %0t", $time);

        inst = 32'h00500293;
        opcode = OP_ALUI;
        #40;
        assert(immediate_extended == 32'h00000005) else $fatal(1,"Assertion failed: immediate != 0000_0005 at time %0t", $time);

        $finish;
    end

    always @(posedge clk) begin
        $display("time %2t, inst = %8h, opcode = %7b, inst = %8h", $time, inst, opcode, immediate_extended);
    end 
  
    initial begin
        $dumpfile("../../../../../../sim/sign_extension.vcd");
        $dumpvars;  
    end

endmodule
