/*
    File name: data_mem.sv
    Description: This file contains the module for the data memory.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

module data_memory #(
    // MEM_SIZE in Words (1024 * 4)
    parameter MEM_SIZE = 1024
) (
    input wire clk_i,
    input wire rst_n_i,
    input wire we_i,
    input wire [DATA_WIDTH - 1:0] data_i,
    input wire [$clog2(MEM_SIZE) - 1:0] addr_i,
    output wire [DATA_WIDTH - 1:0] data_o
);

    logic [DATA_WIDTH - 1:0] memory [0:MEM_SIZE-1];

    always_ff @(posedge clk_i or negedge rst_n_i) begin
       if (!rst_n_i) begin
            for (int i = 0; i < MEM_SIZE; i = i + 1) begin
                memory[i] = 0;  // Initialize each memory location to 0
            end
       end else if (we_i) begin
                memory[addr_i >> 2] <= data_i;
       end
    end

    // Data output sensitive to memory register.
    assign data_o = memory[addr_i >> 2];

endmodule            