/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

import tap_pkg::*;

module tap_DataRegister (
    input logic tck_i,
    input logic trst_i,
    input logic shiftDR_i,
    input logic updateDR_i,
    input logic tdi_i,
    input logic drEna_i,
    output logic tdo_o,
    output logic wEn_o,
    output logic [globalAddress_width-1:0] loadAddr_o,  // Address to load
    output logic [data_width-1:0] loadData_o  // Data to load
);


    logic [95:0] dr_s; // 64-bit address + 32-bit data

    always_ff @(posedge tck_i or posedge trst_i) begin
        if(trst_i)
            dr_s <= '0;
        else if (shiftDR_i && drEna_i) begin
            dr_s <= {tdi_i, dr_s[95:1]}; // Shift in data
        end
    end

    assign tdo_o = dr_s[0]; // Output least significant bit during shifting

    always_ff @(posedge tck_i) begin
        if (updateDR_i && drEna_i) begin 
            loadAddr_o <= dr_s[63:0]; // Extract address
            loadData_o <= dr_s[95:64];  // Extract data
            wEn_o <= 1;
        end else begin
            loadAddr_o <= 0;
            loadData_o <= 0;
            wEn_o <= 0;   
        end
    end

endmodule