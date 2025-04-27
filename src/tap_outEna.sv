/*
    File name: tap_outEna.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 28.04.2025
*/

`timescale 1ns / 10ps

module tap_outEna(
    input logic dIn_i,
    input logic ena_i,
    output logic dOut_o
);
    
assign dOut_o = ena_i ? dIn_i : 1'bz;

endmodule