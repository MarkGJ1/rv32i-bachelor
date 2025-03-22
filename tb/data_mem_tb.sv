/*
    File name: data_mem_tb.sv
    Description: This file contains the testbench for the data memory.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module data_mem_tb;

    localparam MEM_SIZE = 1024;

    logic clk;
    logic rst;
    logic we;
    logic [DATA_WIDTH - 1:0] data_i = 32'h0000_0000;
    logic [$clog2(MEM_SIZE) - 1:0] addr = 32'h0000_0000;

    wire [DATA_WIDTH - 1:0] data_o;

    data_memory dut(
        .clk_i(clk),
        .rst_n_i(rst),
        .we_i(we),
        .addr_i(addr),
        .data_i(data_i),
        .data_o(data_o)
    );

    // Simulation-purposes only.
    initial begin
        // Load memory contents from a file, or set defaults
        $readmemh("../../../../../../tb/data_memory.txt", dut.memory);
    end

    // Clock reset.
    initial clk = 1'b0;
    // Matching Tang Nano 9K crystal frequency.
    always #18.52 clk = ~clk;

    initial begin
            we = 1'b0;
        #37.04;
            addr = 32'h0000_0004;
            assert(data_o == 32'h0000_0000) else $fatal(1,"Assertion failed: data_o != 0000_0000 at time %0t", $time);
        #37.04;
            addr = 32'h0000_0008;
            assert(data_o == 32'h0000_0001) else $fatal(1,"Assertion failed: data_o != 0000_0001 at time %0t", $time);
        #37.04;
            // Write data
            we = 1'b1;
            addr = 32'h0000_0000;
            data_i = 32'h0000_0001;
            assert(data_o == 32'h0000_0002) else $fatal(1,"Assertion failed: data_o != 0000_0002 at time %0t", $time);
        #37.04;
            assert(data_o == 32'h0000_0001) else $fatal(1,"Assertion failed: data_o != 0000_0001 at time %0t", $time);
        $finish;
    end

    always @(posedge clk) begin 
        $display("time %2t, clk = %b, we = %b, addr = %3h, data_i = %8h, o_data = %8h", $time, clk, we, addr, data_i, data_o);
    end 

    initial begin
        $dumpfile("../../../../../../sim/data_memory.vcd");
        $dumpvars;  
    end
endmodule