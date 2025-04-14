/*
    File name: data_mem.sv
    Description: Data memory is useful for storing data
                during program execution, commonly known
                as Random Access Memory (RAM).
    Author: Marko Gjorgjievski
    Date created: 15.03.2025
    Date modified: 13.04.2025
*/

import pkg_config::*;

module data_memory #(
    // MEM_SIZE in Words (1024 * 4)
    parameter MEM_SIZE = 1024
) (
    input wire clk_i,
    input wire we_i,
    input wire [DATA_WIDTH - 1:0] data_i,
    input wire [$clog2(MEM_SIZE) - 1:0] addr_i,
    output logic [DATA_WIDTH - 1:0] data_o
);

    logic [DATA_WIDTH - 1:0] memory [0:MEM_SIZE-1];

    always @(posedge clk_i) begin
        if (we_i) begin
            memory[addr_i >> 2] <= data_i;
        end
    end
    
    // Data output sensitive to memory register.
    assign data_o = memory[addr_i >> 2];

endmodule            