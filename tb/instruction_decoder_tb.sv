/*
File name: instruction_decoder_tb.sv
Description: This file contains the testbench for the instruction decoder.
Author(s): Bitspinner, Marko Gjorgjievski
Date: 15.03.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module decoder_tb;

    logic clk;
    logic [INST_WIDTH - 1:0] inst = 32'h00000000;
    wire [OPCODE - 1:0] opcode;
    wire branch;
    wire [1:0] result_mux;
    wire [2:0] branch_op;
    wire mem_write;
    wire alu_src_a;
    wire alu_src_b;
    wire reg_write;
    wire [5:0] alu_op;
    wire [$clog2(NUM_REGISTER) - 1:0] rs1_addr;
    wire [$clog2(NUM_REGISTER) - 1:0] rs2_addr;
    wire [$clog2(NUM_REGISTER) - 1:0] rd_addr;

    decoder dut (
        .inst_i(inst),
        .opcode_o(opcode),
        .branch_o(branch),
        .result_mux_o(result_mux),
        .branch_op_o(branch_op),
        .mem_write_o(mem_write),
        .alu_src_a_o(alu_src_a),
        .alu_src_b_o(alu_src_b),
        .reg_write_o(reg_write),
        .alu_op_o(alu_op),
        .rs1_addr_o(rs1_addr),
        .rs2_addr_o(rs2_addr),
        .rd_addr_o(rd_addr)
    );


    initial  clk = 1'b0;

    always #18.52 clk = ~clk;

    initial begin
        inst = 32'h0007b2b7; //lui x5, 123
        #37.04;
        assert(dut.opcode_o == OP_LUI)      else $fatal(1,"Assertion failed: dut.opcode_o != OP_LUI at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 0 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        //assert(dut.o_rs1_addr, 5'b00100);
        //assert(dut.o_rs2_addr, 5'b00000);
        assert(dut.rd_addr_o == 5'b00101)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 00101 at time %0t", $time);

        inst = 32'h0007b297; //auipc x5, 123
        #37.04;
        assert(dut.opcode_o == OP_AUIPC)    else $fatal(1,"Assertion failed: dut.opcode_o != OP_AUIPC at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 0 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 1 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        //assert(dut.o_rs1_addr, 5'b00101);
        //assert(dut.o_rs2_addr, 5'b00000);
        assert(dut.rd_addr_o == 5'b00101)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 00101 at time %0t", $time);

        inst = 32'h4d000bef; //jal x23, 1232
        #37.04;
        assert(dut.opcode_o == OP_JAL)      else $fatal(1,"Assertion failed: dut.opcode_o != OP_JAL at time %0t", $time);
        assert(dut.branch_o == 1'b1)        else $fatal(1,"Assertion failed: dut.branch_o != 1 at time %0t", $time);
        assert(dut.result_mux_o == 2'b01)   else $fatal(1,"Assertion failed: dut.result_mux_o != 01 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 1 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.branch_op_o == BRANCH_JAL_JALR) else $fatal(1,"Assertion failed: dut.branch_op_o != BRANCH_JAL_JALR at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        //assert(dut.o_rs1_addr, 5'b00101);
        //assert(dut.o_rs2_addr, 5'b00000);
        assert(dut.rd_addr_o == 5'b10111)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 10111 at time %0t", $time);

        inst = 32'h4d000be7; //jalr x23, 1232(x0)
        #37.04;
        assert(dut.opcode_o == OP_JALR)     else $fatal(1,"Assertion failed: dut.opcode_o != OP_JALR at time %0t", $time);
        assert(dut.branch_o == 1'b1)        else $fatal(1,"Assertion failed: dut.branch_o != 1 at time %0t", $time);
        assert(dut.result_mux_o == 2'b01)   else $fatal(1,"Assertion failed: dut.result_mux_o != 01 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.branch_op_o == BRANCH_JAL_JALR) else $fatal(1,"Assertion failed: dut.branch_op_o != BRANCH_JAL_JALR at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        //assert(dut.o_rs1_addr, 5'b00101);
        //assert(dut.o_rs2_addr, 5'b00000);
        assert(dut.rd_addr_o == 5'b10111)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 10111 at time %0t", $time);

        inst = 32'h03924563; //blt x4, x25, 42
        #37.04;
        assert(dut.opcode_o == OP_BRANCH)   else $fatal(1,"Assertion failed: dut.opcode_o != OP_BRANCH at time %0t", $time);
        assert(dut.branch_o == 1'b1)        else $fatal(1,"Assertion failed: dut.branch_o != 1 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 0 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 1 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.branch_op_o == BRANCH_BLT) else $fatal(1,"Assertion failed: dut.branch_op_o != BRANCH_BLT at time %0t", $time);
        assert(dut.reg_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.reg_write_o != 0 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        assert(dut.rs1_addr_o == 5'b00100)  else $fatal(1,"Assertion failed: dut.rs1_addr_o != 00100 at time %0t", $time);
        assert(dut.rs2_addr_o == 5'b11001)  else $fatal(1,"Assertion failed: dut.rs2_addr_o != 11001 at time %0t", $time);
        //assert(dut.o_rd_addr, 5'b10111);

        inst = 32'h01713703; //ld x14, 23(x2)
        #37.04;
        assert(dut.opcode_o == OP_LOAD)     else $fatal(1,"Assertion failed: dut.opcode_o != OP_LOAD at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b10)   else $fatal(1,"Assertion failed: dut.result_mux_o != 10 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        //assert(dut.branch_op_o == BRANCH_BLT) else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        assert(dut.rs1_addr_o == 5'b00010)  else $fatal(1,"Assertion failed: dut.rs1_addr_o != 00010 at time %0t", $time);
        //assert(dut.rs2_addr_o == 5'b11001) else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.rd_addr_o == 5'b01110)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 01110 at time %0t", $time);

        inst = 32'h00e12ba3; //sw x14, 23(x2)
        #37.04;
        assert(dut.opcode_o == OP_STORE)    else $fatal(1,"Assertion failed: dut.opcode_o != OP_STORE at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 00 at time %0t", $time);
        assert(dut.mem_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.mem_write_o != 1 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        //assert(dut.branch_op_o == BRANCH_BLT) else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.reg_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.reg_write_o != 0 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        assert(dut.rs1_addr_o == 5'b00010)  else $fatal(1,"Assertion failed: dut.rs1_addr_o != 00010 at time %0t", $time);
        assert(dut.rs2_addr_o == 5'b01110)  else $fatal(1,"Assertion failed: dut.rs2_addr_o != 01110 at time %0t", $time);

        inst = 32'h00f0c1b3; //xor x3, x1, x15
        #37.04;
        assert(dut.opcode_o == OP_ALU)      else $fatal(1,"Assertion failed: dut.opcode_o != OP_ALU at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 0 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 0 at time %0t", $time);
        //assert(dut.branch_op_o == BRANCH_BLT) else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_XOR)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_XOR at time %0t", $time);
        assert(dut.rs1_addr_o == 5'b00001)  else $fatal(1,"Assertion failed: dut.rs1_addr_o != 00001 at time %0t", $time);
        assert(dut.rs2_addr_o == 5'b01111)  else $fatal(1,"Assertion failed: dut.rs2_addr_o != 01111 at time %0t", $time);
        assert(dut.rd_addr_o == 5'b00011)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 00011 at time %0t", $time);

        inst = 32'h02020113; //addi x2, x4, 32
        #37.04;
        assert(dut.opcode_o == OP_ALUI)     else $fatal(1,"Assertion failed: dut.opcode_o != OP_ALUI at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 0 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        assert(dut.rs1_addr_o == 5'b00100)  else $fatal(1,"Assertion failed: dut.rs1_addr_o != 00100 at time %0t", $time);
        //assert(dut.rs2_addr_o == 5'b00000) else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.rd_addr_o == 5'b00010)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 00010 at time %0t", $time);

        inst = 32'h00C00293; // addi x5, x0, 12
        #37.04;
        assert(dut.opcode_o == OP_ALUI)     else $fatal(1,"Assertion failed: dut.opcode_o != OP_ALUI at time %0t", $time);
        assert(dut.branch_o == 1'b0)        else $fatal(1,"Assertion failed: dut.branch_o != 0 at time %0t", $time);
        assert(dut.result_mux_o == 2'b00)   else $fatal(1,"Assertion failed: dut.result_mux_o != 0 at time %0t", $time);
        assert(dut.mem_write_o == 1'b0)     else $fatal(1,"Assertion failed: dut.mem_write_o != 0 at time %0t", $time);
        assert(dut.alu_src_a_o == 1'b0)     else $fatal(1,"Assertion failed: dut.alu_src_a_o != 0 at time %0t", $time);
        assert(dut.alu_src_b_o == 1'b1)     else $fatal(1,"Assertion failed: dut.alu_src_b_o != 1 at time %0t", $time);
        assert(dut.reg_write_o == 1'b1)     else $fatal(1,"Assertion failed: dut.reg_write_o != 1 at time %0t", $time);
        assert(dut.alu_op_o == OP_ALU_ADD)  else $fatal(1,"Assertion failed: dut.alu_op_o != OP_ALU_ADD at time %0t", $time);
        assert(dut.rs1_addr_o == 5'b00000)  else $fatal(1,"Assertion failed: dut.rs1_addr_o != 00100 at time %0t", $time);
        assert(dut.rd_addr_o == 5'b00101)   else $fatal(1,"Assertion failed: dut.rd_addr_o != 00010 at time %0t", $time);

        $finish;
    end

    always @(posedge clk) begin 
        $display("time %2t, inst = %8h, opcode = %7b, branch = %b, result_mux = %2b, branch_op = %3b, mem_write = %b, alu_src_a = %b, alu_src_b = %b, reg_write = %b, alu_op = %5b, rs1_addr = %5b, rs2_addr = %5b, rd_addr = %5b", $time, inst, opcode, branch, result_mux, branch_op, mem_write, alu_src_a, alu_src_b, reg_write, alu_op, rs1_addr, rs2_addr, rd_addr);    
    end 

    initial begin
        $dumpfile("../../../../../../sim/decoder.vcd");
        $dumpvars;  
    end

endmodule