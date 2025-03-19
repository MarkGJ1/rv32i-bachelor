/*
    File name: instr_mem_tb.sv
    Description: Testbench for instruction memory file.
    Author: Marko Gjorgjievski
    Date: 13.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module inst_mem_tb;

    localparam MEM_SIZE = 1024;
    logic [$clog2(MEM_SIZE)-1:0] addr = 32'h00000000;
    wire [INST_WIDTH-1:0] inst;

    instruction_memory dut (
        .addr_i(addr),
        .inst_o(inst)
    );
  
    // Simulation-purposes only.
    initial begin
        // Load memory contents from a file, or set defaults
        $readmemh("../../../../../../tb/instruction_memory.txt", dut.memory);
    end

    initial begin
        #10;
            assert(inst == 32'h00108113) else $fatal(1,"Assertion failed: inst != 32'h00108113 at time %0t", $time); 
        #10;
            addr = 32'h00000004;
        #10;
            assert(inst == 32'h00108193) else $fatal(1,"Assertion failed: inst != 32'h00108193 at time %0t", $time); 
        #10;
            addr = 32'h00000008;
        #10;
            assert(inst == 32'h00310233) else $fatal(1,"Assertion failed: inst != 32'h00310233 at time %0t", $time); 
        #10;
            addr = 32'h0000000c;
        #10;
            assert(inst == 32'hfe218ae3) else $fatal(1,"Assertion failed: inst != 32'hfe218ae3 at time %0t", $time); 
        #10;
            addr = 32'h00000010;
        #10;
            assert(inst == 32'h00000000) else $fatal(1,"Assertion failed: inst != 32'h00000000 at time %0t", $time); 
        $finish;
    end

    always @* begin 
        $display("time %2t, addr = %3h, inst = %8h", $time, addr, inst);
    end 

    initial begin
        $dumpfile("../../../../../../sim/inst_mem.vcd");
        $dumpvars;  
    end

endmodule
