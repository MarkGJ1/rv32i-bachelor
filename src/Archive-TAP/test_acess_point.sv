/*
    File name: tap_top_official.sv
    Description: 
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

`timescale 1ns / 10ps

import tap_pkg::*;
import pkg_config::*; // TODO: Rename pkg_config to rv32i_pkg after thesis and do timescale for warnings in every module.

// Missing internal signals
// Missing connections between modules.
// TODO: Data-reg mux + IR decoder.

module test_access_point (
    input logic TCK_i;
    input logic TDI_i;
    input logic TRST_i;
    input logic TMS_i;
    output logic TDO_o
);

    tap_controller Controller(

    );

    tap_instruction_register IR(

    );

    tap_instruction_decoder DEC(

    );

    tap_tdo_mux tdo_mux(

    );

    tap_dff D_ff(

    );

    tap_bs_register DUT (

    );

    tap_bypass_reg bypass_reg (

    );

    tap_outEna enableReg(

    );

endmodule