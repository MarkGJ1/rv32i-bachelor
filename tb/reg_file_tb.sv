/*
    File name: reg_file_tb.sv
    Description: Testbench for register file.
    Author: Marko Gjorgjievski
    Date: 13.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module reg_file_tb;

    reg clk;
    reg rst;
    reg we;

    reg [$clog2(NUM_REGISTER)-1:0] rd_addr;
    reg [DATA_WIDTH-1:0] rd;

    reg [$clog2(NUM_REGISTER)-1:0] rs1_addr;
    reg [$clog2(NUM_REGISTER)-1:0] rs2_addr;

    wire [DATA_WIDTH-1:0] rs1;
    wire [DATA_WIDTH-1:0] rs2;

    register_file dut(
        .clk_i(clk),
        .rst_n_i(rst),
        .we_i(we),
        .rd_addr_i(rd_addr),
        .rd_i(rd),
        .rs1_addr_i(rs1_addr),
        .rs2_addr_i(rs2_addr),
        .rs1_o(rs1),
        .rs2_o(rs2)  // Fixed: Was incorrectly named `rd2`
    );

    initial begin
        clk = 1'b0;
    end
    
    always #18.52 clk = ~clk;

    initial begin
            rst = 1'b0;
        #10;
            we = 1'b0;
            rst = 1'b1;
            rs1_addr = 5'b00000;
            rs2_addr = 5'b00000;
        #27.04;
            assert(dut.rs1_o == 32'h0000_0000) else $fatal("Assertion failed: rs1_o != 0 at time %0t", $time);
            assert(dut.rs2_o == 32'h0000_0000) else $fatal("Assertion failed: rs2_o != 0 at time %0t", $time);
            rs1_addr = 5'b00001;
            rs2_addr = 5'b00010;
            we = 1'b1;
            rd_addr = 5'b00001;
            rd = 32'h0000_0001;
        #37.04;
            assert(dut.rs1_o == 32'h0000_0001) else $fatal("Assertion failed: rs1_o != 1 at time %0t", $time);
            assert(dut.rs2_o == 32'h0000_0000) else $fatal("Assertion failed: rs2_o != 2 at time %0t", $time);
            rs1_addr = 5'b11111;
            rs2_addr = 5'b00000;
            rd_addr = 5'b11111;
            rd = 32'hffff_ffff;
        #37.04;
            assert(dut.rs1_o == 32'hffff_ffff) else $fatal("Assertion failed: rs1_o != ffffffff at time %0t", $time);
            assert(dut.rs2_o == 32'h0000_0000) else $fatal("Assertion failed: rs2_o != 0 at time %0t", $time);
            rs1_addr = 5'b11111;
            rs2_addr = 5'b00000;
            rd_addr = 5'b00000;
        #37.04;
            assert(dut.rs1_o == 32'hffff_ffff) else $fatal("Assertion failed: rs1_o != ffffffff at time %0t", $time);
            assert(dut.rs2_o == 32'h0000_0000) else $fatal("Assertion failed: rs2_o != 0 at time %0t", $time);
            we = 1'b0;
        #37.04;
            $finish;
    end

    always @(posedge clk) begin
        $display("clk = %b, rst = %b, we = %b, rd_addr = %5b, rd = %8h, rs1_addr = %5b, rs2_addr = %5b, rs1 = %8h, rs2 = %8h", clk, rst, we, rd_addr, rd, rs1_addr, rs2_addr, rs1, rs2);
    end

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars;
    end

endmodule
