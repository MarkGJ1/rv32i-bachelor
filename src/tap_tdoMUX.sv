`timescale 1ns / 1ps

module pb_tdoMux(
    input logic IR_TDO_i,
    input logic DR_TDO_i,
    input logic sel_i,
    output logic TDO_o
);

    assign TDO_o = (sel_i) ? IR_TDO_i : DR_TDO_i;
  
endmodule
