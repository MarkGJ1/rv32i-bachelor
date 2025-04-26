/*
    File name: tap_dff.sv
    Description: Add testbench later.
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

module tap_dff(
    input logic tck_i,
    input logic trst_i,
    input logic d_i,
    output logic q_o
    );
    
    always_ff @(negedge tck_i or posedge trst_i) begin
        if(trst_i)
            q_o <= 1'b0;
        else
            q_o <= d_i;
    end
endmodule