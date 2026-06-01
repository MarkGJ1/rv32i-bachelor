/*
    File name: tap_bypass_reg.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

module tap_bypass_reg (
    input logic tck_i,
    input logic tdi_i,
    input logic bypassEna_i,
    output logic tdo_o
);

    always_ff @(posedge tck_i) begin
        if(bypassEna_i) begin
            tdo_o <= tdi_i; //Only simple shifting
        end
    end

endmodule