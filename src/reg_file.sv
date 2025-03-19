/*
    File name: reg_file.sv
    Description: This file describes the register file.
    Author: Marko Gjorgjievski
    Date: 13.01.2025
*/

import pkg_config::*;

module register_file (
    input wire clk_i,
    input wire rst_n_i, // Active-low reset
    input wire we_i,
    input wire [$clog2(NUM_REGISTER)-1:0] rd_addr_i,
    input wire [DATA_WIDTH-1:0] rd_i,
    input wire [$clog2(NUM_REGISTER)-1:0] rs1_addr_i,
    input wire [$clog2(NUM_REGISTER)-1:0] rs2_addr_i,

    output wire [DATA_WIDTH-1:0] rs1_o,
    output wire [DATA_WIDTH-1:0] rs2_o
);
    // 32 registers, each 32 bits wide
    logic [DATA_WIDTH-1:0] registers [NUM_REGISTER-1:0];
    integer i;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin // Active-low reset
            for (i = 0; i < NUM_REGISTER; i = i + 1) begin
                registers[i] <= 0;  // Use non-blocking assignment for registers
            end
        end else begin
            if (we_i && rd_addr_i != 0) begin
                registers[rd_addr_i] <= rd_i;
            end
        end
    end

    assign rs1_o = registers[rs1_addr_i];
    assign rs2_o = registers[rs2_addr_i];
    
endmodule