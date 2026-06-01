/*
    File name: tap_bsr.sv
    Description: TODO: Include your internal logic and your boundary scan cells connected to it.
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

`timescale 1ns / 10ps

module tap_tdo_mux(
    input logic IR_TDO_i,
    input logic DR_TDO_i,
    input logic sel_i,
    output logic TDO_o
);

    assign TDO_o = (sel_i) ? IR_TDO_i : DR_TDO_i;

endmodule
