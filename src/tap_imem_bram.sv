/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

import tap_pkg::*;

module tap_imem_bram(
    input   logic tck_i,                // Clock for writing (TestClock from JTAG)
    input   logic clk_i,                // Clock for reading (Processor Clock)
    input   logic [ramAddress_width-1:0] addr_i,              // Read address (Processor side)
    input   logic [ramAddress_width-1:0] loadAddr_i,          // Write address (TestClock side)
    input   logic [data_width-1:0] loadData_i,          // Data to be written (TestClock side)
    input   logic wEn_i,                                // Write enable (TestClock side)
    output  logic [data_width-1:0] data_o               // Data output (Processor side)
    );
  
    // Dual-port memory array
    (* ram_style = "block" *) logic [data_width-1:0] ram_s [0:memdepth-1];

    // Port A: Write interface (TestClock domain)
    always_ff @(posedge tck_i) begin
        if (wEn_i) begin
            ram_s[loadAddr_i] <= loadData_i; // Write operation
        end
    end

    // Port B: Read interface (Processor Clock domain)
    always_ff @(posedge clk_i) begin
        data_o <= ram_s[addr_i];          // Read operation
    end

endmodule