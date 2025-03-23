/*
    File name: ALU.sv
    Description: This file contains the module for the ALU.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module top (
    input wire clk,
    input wire rst,
    output wire [DATA_WIDTH-1:0] debug
);
	
    wire [INST_WIDTH-1:0] immediate;
    wire branch;
    wire [1:0] result_mux;
    wire [5:0] alu_op;
    wire [2:0] branch_op;
    wire mem_write;
    wire alu_src_a;
    wire alu_src_b;
    wire reg_write;
  	wire take;
    wire [OPCODE-1:0] opcode;
    wire [$clog2(NUM_REGISTER) - 1: 0] rs1_addr;
    wire [$clog2(NUM_REGISTER) - 1: 0] rs2_addr;
  	wire [$clog2(NUM_REGISTER) - 1: 0] rd_addr;
  	wire [DATA_WIDTH-1:0] rs1;     
    wire [DATA_WIDTH-1:0] rs2;
    logic [DATA_WIDTH-1:0] rd;
  	wire [DATA_WIDTH-1:0] sel_alu_src_a;
    wire [DATA_WIDTH-1:0] sel_alu_src_b;
  	wire [INST_WIDTH-1:0] inst;

  	logic [DATA_WIDTH-1:0] data;
    logic [DATA_WIDTH-1:0] pc;
  	logic [DATA_WIDTH-1:0] result;

    always_ff @(posedge clk or negedge rst) begin 
        if(!rst) begin
            pc <= 0;
        end else begin
            if(take) begin 
                pc <= rd;
            end else begin
                pc <= pc + 4;
            end
        end
    end
    
    instruction_memory imem (
        .addr_i(pc),
        .rst_n_i(rst),
        .inst_o(inst)
    );        
    
    data_memory dmem (
        .clk_i(clk),
        .rst_n_i(rst),
        .we_i(mem_write),
        .addr_i(rd),
        .data_i(rs2),
        .data_o(data)
    );        

    always @* begin
        case (result_mux)
            2'b00: result = rd;
            2'b01: result = pc + 4;
            2'b10: result = data;
            default: result = 32'b0;
        endcase
    end

    assign debug = result;

    sign_extension sign_ext (
        .inst_i(inst),
        .opcode_i(opcode),
        .immediate_extended_o(immediate)
    );          

    decoder dec (
        .inst_i(inst),
        .branch_o(branch),
        .result_mux_o(result_mux),
        .alu_op_o(alu_op),
        .branch_op_o(branch_op),
        .mem_write_o(mem_write),
        .alu_src_a_o(alu_src_a),
        .alu_src_b_o(alu_src_b),
        .reg_write_o(reg_write),
        .opcode_o(opcode),
        .rs1_addr_o(rs1_addr),
        .rs2_addr_o(rs2_addr),
        .rd_addr_o(rd_addr)
    );    
    
    register_file reg_file (
        .clk_i(clk),
        .rst_n_i(rst),
        .we_i(reg_write),
        .rd_addr_i(rd_addr),
        .rd_i(result),
        .rs1_addr_i(rs1_addr),
        .rs2_addr_i(rs2_addr),
        .rs1_o(rs1),
        .rs2_o(rs2)
    );
   
    assign sel_alu_src_a = (alu_src_a == 0) ? rs1 : pc;
    assign sel_alu_src_b = (alu_src_b == 0) ? rs2 : immediate;
    
    alu_unit alu (
        .alu_op_i(alu_op),
        .a_i(sel_alu_src_a),
        .b_i(sel_alu_src_b),
        .c_o(rd)
    );
       
    branch_unit b (
        .branch_i(branch),
        .branch_op_i(branch_op),
        .a_i(rs1),
        .b_i(rs2),
        .take_o(take)
    );

endmodule