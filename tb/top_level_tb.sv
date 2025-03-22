/*
    File name: ALU.sv
    Description: This file contains the module for the ALU.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module top_tb;

    logic rst;
    logic clk;
    wire [DATA_WIDTH - 1:0] debug = 32'h00000000;

    top dut (
        .rst(rst),
        .clk(clk),
        .debug(debug)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b0; #5;
        rst = 1'b1;
        //$readmemh("../../../../../../tb/fibonacci_inst_mem.txt", dut.imem.memory);
        $readmemh("../../../../../../tb/simple_add.txt", dut.imem.memory);
        //$readmemh("../../../../../../tb/fibonacci_data_mem.txt", dut.dmem.memory);
    end

    always #18.52 clk = ~clk;

    always @(posedge clk) begin 
        $display("time = %2t, clk = %b, rst = %b, pc = %8h, opcode_o = %b, inst = %8h, res_mux = %2b", $time, clk, rst, dut.pc, dut.dec.opcode_o, dut.inst, dut.result_mux);
        $display("rd_addr = %5b, ALU output = %5d, ALU_a = %5d, ALU_b = %5d", dut.rd_addr, dut.alu.c_o, dut.alu.a_i, dut.alu.b_i);
        $display("rs1 = %5b, rs2 = %5d, rs1_addr = %5d, rs2_addr = %5d", dut.rs1, dut.rs2, dut.dec.rs1_addr_o, dut.dec.rs2_addr_o);
        $display("zero = %8h  ra = %8h  sp = %8h  gp = %8h", dut.reg_file.registers[0], dut.reg_file.registers[1], dut.reg_file.registers[2], dut.reg_file.registers[3]);
        $display("  tp = %8h  t0 = %8h  t1 = %8h  t2 = %8h", dut.reg_file.registers[4], dut.reg_file.registers[5], dut.reg_file.registers[6], dut.reg_file.registers[7]);
        $display("  s0 = %8h  s1 = %8h  a0 = %8h  a1 = %8h", dut.reg_file.registers[8], dut.reg_file.registers[9], dut.reg_file.registers[10], dut.reg_file.registers[11]);
        $display("  a2 = %8h  a3 = %8h  a4 = %8h  a5 = %8h", dut.reg_file.registers[12], dut.reg_file.registers[13], dut.reg_file.registers[14], dut.reg_file.registers[15]);
        $display("  a6 = %8h  a7 = %8h  s2 = %8h  s3 = %8h", dut.reg_file.registers[16], dut.reg_file.registers[17], dut.reg_file.registers[18], dut.reg_file.registers[19]);
        $display("  s4 = %8h  s5 = %8h  s6 = %8h  s7 = %8h", dut.reg_file.registers[20], dut.reg_file.registers[21], dut.reg_file.registers[22], dut.reg_file.registers[23]);
        $display("  s8 = %8h  s9 = %8h s10 = %8h s11 = %8h", dut.reg_file.registers[24], dut.reg_file.registers[25], dut.reg_file.registers[26], dut.reg_file.registers[27]);
        $display("  t3 = %8h  t4 = %8h  t5 = %8h  t6 = %8h", dut.reg_file.registers[28], dut.reg_file.registers[29], dut.reg_file.registers[30], dut.reg_file.registers[31]);
    end

    always @(posedge clk) begin 
            case (dut.opcode)
            OP_LUI: begin  // LUI
                $display("OP_LUI is checked at time %2t", $time);
                assert(dut.branch == 1'b0)      else $fatal(1,"Assertion failed: dut.branch     != 0 at time %0t", $time);
                assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take       != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b00) else $fatal(1,"Assertion failed: dut.result_mux != 0 at time %0t", $time);
                assert(dut.alu_src_a == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 0 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_AUIPC: begin  // AUIPC
                assert(dut.branch == 1'b0)      else $fatal(1,"Assertion failed: dut.branch     != 0 at time %0t", $time);
                assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take       != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b00) else $fatal(1,"Assertion failed: dut.result_mux != 0 at time %0t", $time);
                assert(dut.alu_src_a == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 1 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_JAL: begin  // JAL
                assert(dut.branch == 1'b1)      else $fatal(1,"Assertion failed: dut.branch     != 1 at time %0t", $time);
                assert(dut.take == 1'b1)        else $fatal(1,"Assertion failed: dut.take       != 1 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b01) else $fatal(1,"Assertion failed: dut.result_mux != 01 at time %0t", $time);
                assert(dut.alu_src_a == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 1 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_JALR : begin  // JALR
                assert(dut.branch == 1'b1)      else $fatal(1,"Assertion failed: dut.branch     != 1 at time %0t", $time);
                assert(dut.take == 1'b1)        else $fatal(1,"Assertion failed: dut.take       != 1 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b01) else $fatal(1,"Assertion failed: dut.result_mux != 01 at time %0t", $time);
                assert(dut.alu_src_a == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 0 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_BRANCH: begin  // Branch Instructions
                if(dut.take)
                    assert(dut.branch == 1'b1)      else $fatal(1,"Assertion failed: dut.branch != 1 at time %0t", $time);
                if(!dut.branch)
                    assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take   != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b00) else $fatal(1,"Assertion failed: dut.result_mux != 0 at time %0t", $time);
                assert(dut.alu_src_a == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 1 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_LOAD: begin  // Load Instructions
                assert(dut.branch == 1'b0)      else $fatal(1,"Assertion failed: dut.branch     != 0 at time %0t", $time);
                assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take       != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b10) else $fatal(1,"Assertion failed: dut.result_mux != 10 at time %0t", $time);
                assert(dut.alu_src_a == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 0 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_STORE: begin  // Store Instructions
                assert(dut.branch == 1'b0)      else $fatal(1,"Assertion failed: dut.branch     != 0 at time %0t", $time);
                assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take       != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b1)   else $fatal(1,"Assertion failed: dut.mem_write  != 1 at time %0t", $time);
                assert(dut.result_mux == 2'b00) else $fatal(1,"Assertion failed: dut.result_mux != 0 at time %0t", $time);
                assert(dut.alu_src_a == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 0 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);      
            end
            OP_ALU: begin  // ALU Instructions
                assert(dut.branch == 1'b0)      else $fatal(1,"Assertion failed: dut.branch     != 0 at time %0t", $time);
                assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take       != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b00) else $fatal(1,"Assertion failed: dut.result_mux != 00 at time %0t", $time);
                assert(dut.alu_src_a == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 0 at time %0t", $time);
                assert(dut.alu_src_b == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 0 at time %0t", $time);
            end
            OP_ALUI: begin // Implement ADDI, ANDI, ORI, XORI, etc.
                assert(dut.branch == 1'b0)      else $fatal(1,"Assertion failed: dut.branch     != 0 at time %0t", $time);
                assert(dut.take == 1'b0)        else $fatal(1,"Assertion failed: dut.take       != 0 at time %0t", $time);
                assert(dut.mem_write == 1'b0)   else $fatal(1,"Assertion failed: dut.mem_write  != 0 at time %0t", $time);
                assert(dut.result_mux == 2'b00) else $fatal(1,"Assertion failed: dut.result_mux != 00 at time %0t", $time);
                assert(dut.alu_src_a == 1'b0)   else $fatal(1,"Assertion failed: dut.alu_src_a  != 0 at time %0t", $time);
                assert(dut.alu_src_b == 1'b1)   else $fatal(1,"Assertion failed: dut.alu_src_b  != 1 at time %0t", $time);
            end
            OP_FENCE: begin  // Fence
                $fatal(1, "Fatal error occurred!");
                // Implement fence instruction
            end
            OP_SYSTEM: begin  // System Instructions
                // ImplemeAnt ECALL, EBREAK, etc.
                $display("End of Simulation");
                $finish;
                //$fatal(1, "Fatal error occurred!");
            end
            default: begin
                // Handle unrecognized opcodes
                $fatal(1, "Fatal error occurred!");
            end
        endcase
    end

    initial begin
        $dumpfile("../../../../../../sim/top.vcd");
        $dumpvars;  
    end

endmodule