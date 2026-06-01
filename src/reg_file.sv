/*
    File name: reg_file.sv
    Description: Register file describes the data width and number of
                RV32I registers used for temporary data storage during operation.
    Author: Marko Gjorgjievski
    Date created: 13.01.2025
    Date modified: 14.04.2025
*/

import pkg_config::*;

module register_file (
    input logic clk_i,
    input logic rst_n_i, // Active-low reset
    input logic we_i,
    input logic [$clog2(NUM_REGISTER)-1:0] rd_addr_i,
    input logic [DATA_WIDTH-1:0] rd_i,
    input logic [$clog2(NUM_REGISTER)-1:0] rs1_addr_i,
    input logic [$clog2(NUM_REGISTER)-1:0] rs2_addr_i,

    output logic [DATA_WIDTH-1:0] rs1_o,
    output logic [DATA_WIDTH-1:0] rs2_o
);
    // 32 registers, each 32 bits wide
    logic [DATA_WIDTH-1:0] registers [NUM_REGISTER-1:0];

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin // Active-low reset
            for (int i = 0; i < NUM_REGISTER; i = i + 1) begin
                registers[i] <= 0;  // Use non-blocking assignment for registers
            end
        end else begin
            if (we_i && rd_addr_i != 0) begin
                registers[rd_addr_i] <= rd_i;
            end
        end
    end

    // Avoiding unknown with ternary operator. 
    // TODO: Test with simulation if necessary after TAP implementation.
    assign rs1_o = (rs1_addr_i === 'x || rs1_addr_i >= NUM_REGISTER) ? 0 : registers[rs1_addr_i];
    assign rs2_o = (rs2_addr_i === 'x || rs2_addr_i >= NUM_REGISTER) ? 0 : registers[rs2_addr_i];
    
endmodule