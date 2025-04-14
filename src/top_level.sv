/*
    File name: top_lvl.sv
    Description: Top Level connecting all components of the rv32i core.
    Author: Marko Gjorgjievski
    Date created: 15.01.2025
    Date modified: 13.04.2025
*/

import pkg_config::*;

`default_nettype none
`timescale 1ns/1ns

module top #(
    // MEM_SIZE in Words
    parameter MEM_SIZE_INST = 1024
)   (
    input wire clk,
    input wire rst,
    output logic [INST_WIDTH - 1:0] debug
);

    /* Internal signals of top.
        TODO: Double check when possible what should constitute
            a wire and what should be logic. Current consesus is
            to use "logic" whenever possible in sysVerilog.
            Proven to be best to use "logic" to avoid unknowns 
            in debug signal. */
    logic [$clog2(MEM_SIZE_INST)-1:0] pc_s; // imem (in), 
    wire  [INST_WIDTH-1:0] inst_s; // imem (out), dec (in)
    wire branch_s;
    wire [1:0] result_mux_s;
    wire [5:0] alu_op_s;
    wire [2:0] branch_op_s;
    wire mem_write_s;
    wire alu_src_a_s;
    wire alu_src_b_s;
    wire reg_write_s;
  	wire take_s;
    wire [OPCODE-1:0] opcode_s;
    wire [$clog2(NUM_REGISTER) - 1: 0] rs1_addr_s;
    wire [$clog2(NUM_REGISTER) - 1: 0] rs2_addr_s;
  	wire [$clog2(NUM_REGISTER) - 1: 0] rd_addr_s;
    wire [DATA_WIDTH-1:0] sel_alu_src_a_s;
    wire [DATA_WIDTH-1:0] sel_alu_src_b_s;
    logic [DATA_WIDTH-1:0] immediate_s;
    wire [DATA_WIDTH-1:0] rs1_s;     
    wire [DATA_WIDTH-1:0] rs2_s;
    logic [DATA_WIDTH-1:0] data_s;
    logic [DATA_WIDTH-1:0] result_s;
    logic [DATA_WIDTH-1:0] rd_s;

    // Reset, increment or point to data --> program counter.
    always_ff @(posedge clk or negedge rst) begin 
        if(!rst) begin
            pc_s <= 0;
        end else begin
            if (take_s) begin 
                pc_s <= rd_s;
            end else begin
                pc_s <= pc_s + 4;
            end
        end
    end

    alu_unit alu (
        .alu_op_i(alu_op_s),
        .a_i(sel_alu_src_a_s),
        .b_i(sel_alu_src_b_s),
        .c_o(rd_s)
    );

    instruction_memory imem (
        .addr_i(pc_s),
        .inst_o(inst_s)
    );

    data_memory dmem (
        .clk_i(clk),
        .we_i(mem_write_s),
        .addr_i(rd_s),
        .data_i(rs2_s),
        .data_o(data_s)
    );

    decoder dec (
        .inst_i(inst_s),
        .branch_o(branch_s),
        .result_mux_o(result_mux_s),
        .alu_op_o(alu_op_s),
        .branch_op_o(branch_op_s),
        .mem_write_o(mem_write_s),
        .alu_src_a_o(alu_src_a_s),
        .alu_src_b_o(alu_src_b_s),
        .reg_write_o(reg_write_s),
        .opcode_o(opcode_s),
        .rs1_addr_o(rs1_addr_s),
        .rs2_addr_o(rs2_addr_s),
        .rd_addr_o(rd_addr_s)
    );

    branch_unit b (
        .branch_i(branch_s),
        .branch_op_i(branch_op_s),
        .a_i(rs1_s),
        .b_i(rs2_s),
        .take_o(take_s)
    );

    register_file reg_file (
        .clk_i(clk),
        .rst_n_i(rst),
        .we_i(reg_write_s),
        .rd_addr_i(rd_addr_s),
        .rd_i(result_s),
        .rs1_addr_i(rs1_addr_s),
        .rs2_addr_i(rs2_addr_s),
        .rs1_o(rs1_s),
        .rs2_o(rs2_s)
    );

    sign_extension sign_ext (
        .inst_i(inst_s),
        .opcode_i(opcode_s),
        .immediate_extended_o(immediate_s)
    );

    // Depending on instruction, debug wire will show relevant result.
    always @* begin
        case (result_mux_s)
            2'b00: result_s = rd_s;
            2'b01: result_s = pc_s + 4;
            2'b10: result_s = data_s;
            default: result_s = 32'b0;
        endcase
    end

    assign debug = result_s;
    assign sel_alu_src_a_s = (alu_src_a_s == 0) ? rs1_s : pc_s;
    assign sel_alu_src_b_s = (alu_src_b_s == 0) ? rs2_s : immediate_s;

endmodule