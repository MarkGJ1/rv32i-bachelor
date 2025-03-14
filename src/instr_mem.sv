/*
    File name: instr_mem.sv
    Description: This file contains the module for the instruction memory.
    Author: Marko Gjorgjievski
    Date: 15.01.2025
*/

import pkg_config::*;

module instruction_memory #(
    // MEM_SIZE in Words
    parameter MEM_SIZE = 1024
)  (
  	input wire [$clog2(MEM_SIZE)-1:0] addr_i,

  	output logic [INST_WIDTH-1:0] inst_o
);

    // synthesis-friendly ROM using a 2D array
    logic [INST_WIDTH-1:0] memory [0:MEM_SIZE-1];

    // Instruction output register dependent on memory register.
    assign inst_o = memory[addr_i >> 2]; 
    
endmodule
