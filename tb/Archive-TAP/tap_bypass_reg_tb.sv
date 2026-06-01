/*
    File name: tap_bypass_reg.sv
    Description: Testbench for the bypass register.
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

import tap_pkg::*;

`default_nettype none
`timescale 1ns/10ps // --> 18.52 clock edges.

module tap_bypass_reg_tb;

    // Testbench signals
    logic tck_i = 0;        // Clock
    logic tdi_i = 0;        // Test Data Input
    logic tdo_o = 0;        // Test Data Output
    logic bypassEna_i = 0;  // Enable bypass register
    logic [7:0] testData_s = 0;     // Test data pattern
    logic [7:0] testResult_s = 0;   // Result register filled.

    // Instantiate the DUT (tap_bypass)
    tap_bypass_reg dut (
        .tck_i(tck_i),
        .tdi_i(tdi_i),
        .bypassEna_i(bypassEna_i),
        .tdo_o(tdo_o)
    );

    // Clock generation
    initial begin
        $display("Starting tap_bypass_reg Testbench...");
        bypassEna_i = 1;
        testData_s = 8'b10101011; // Example test pattern
        forever #18.52 tck_i = ~tck_i; // 18.52 ns clock period matching TANG NANO 9K
    end

    initial begin
        for (int i = 0; i < 8; i++) begin
            @(posedge tck_i)
            assert(tdo_o == tdi_i) else $fatal(1,"Assertion failed tdo_o == tdi_i at time %0t", $time);
            tdi_i = testData_s[i];
            #10ps; //Smallest possible time delay as to fill testResult vector correctly.
            testResult_s[i] = tdo_o; // --> runs at same simulation step...
        end
        
        assert(testData_s == testResult_s) else $fatal(1,"Assertion failed testData_s != testResult_s at time %0t", $time);
        
        #10;
        $display("All bits passed successfully!");
        $finish;
    end

    always @(posedge tck_i) begin 
        $display("time %2t, tdi_i = %b, tdo_o = %b, testResult_s = %b", 
        $time, tdi_i, tdo_o, testResult_s); // tdo_o will be delayed 1 clk cycle.
    end 

    initial begin
        $dumpfile("../../../../../../sim/tap_bypass_reg.vcd");
        $dumpvars;
    end

endmodule