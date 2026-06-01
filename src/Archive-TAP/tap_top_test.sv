`timescale 1ns / 1ps

import pb_pack::*;

module pb_topLevel(
    input trst_i,
    input tdi_i,
    input tms_i,
    input tck_i,
    output tdo_o,
    input clk_i,
    input [globalAddress_width-1:0] readAddr_i,
    output [data_width-1:0] readData_o
    );
    
logic [globalAddress_width-1:0] loadAddr_s;
logic [data_width-1:0] loadData_s;
logic        wEn_s;

   pb_tap_toplevel tap (
        .tck_i(tck_i),
        .tms_i(tms_i),
        .tdi_i(tdi_i),
        .trst_i(trst_i),
        .tdo_o(tdo_o),
        .loadAddr_o(loadAddr_s),
        .loadData_o(loadData_s),
        .wEn_o(wEn_s)
    );
    
    pb_iMem_bram imem(
        .test_clk_i(tck_i),                 // Clock for writing (TestClock from JTAG)
        .proc_clk_i(clk_i),                 // Clock for reading (Processor Clock)
        .addr_i(readAddr_i),                // Read address (Processor side)
        .loadAddr_i(loadAddr_s),            // Write address (TestClock side)
        .loadData_i(loadData_s),            // Data to be written (TestClock side)
        .wEn_i(wEn_s),                      // Write enable (TestClock side)
        .data_o(readData_o)                 // Data output (Processor side)
    );
    

endmodule
