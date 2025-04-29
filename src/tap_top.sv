/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 29.04.2025
*/

import pb_pack::*;

module pb_tap_toplevel (
    input  logic tck_i, tms_i, tdi_i, trst_i,
    output logic tdo_o,
    output logic [globalAddress_width-1:0] loadAddr_o,
    output logic [data_width-1:0] loadData_o,
    output logic        wEn_o
    );

    
    // Internal signals
    logic shiftIR_s, updateIR_s;
    logic shiftDR_s, updateDR_s;
    logic [3:0] instruction_s;
    logic muxBypass_s, muxTDO_s, enaBSR_s, enaBypass_s;
    logic [1:0] regSel_s;
    logic selTDO_s, enaTDO_s, drTDO_s, irTDO_s, dffTDO_s, clkTDO_s;

   
    // TAP Controller
    pb_TAP_Controller tap_ctrl (
        .tck_i(tck_i),   // JTAG clock
        .tms_i(tms_i),   // JTAG mode select
        .trst_i(trst_i),  // JTAG reset
        .shiftIR_o(shiftIR_s),    
        .updateIR_o(updateIR_s),
        .shiftDR_o(shiftDR_s),     
        .updateDR_o(updateDR_s),
        .SelectIR_o(selTDO_s),
        .Enable_o(enaTDO_s)
);

    // Instruction Register
    pb_InstructionRegister ir (
        .tck_i(tck_i),
        .trst_i(trst_i),
        .shiftIR_i(shiftIR_s),
        .updateIR_i(updateIR_s),
        .tdi_i(tdi_i),
        .tdo_o(irTDO_s), // IR shifts data to tdo_o
        .instruction_o(instruction_s)
    );
    
    //Instruction Decoder
    pb_IR_Decoder irDec(
        .irInstruction_i(instruction_s),
        .scanEnable_o(enaBSR_s),
        .bypassEnable_o(enaBypass_s),
        .mux_o(regSel_s),
        .extest_mode_o(),
        .sample_mode_o(),
        .preload_mode_o()
    
    
    );

    // Data Register
    pb_DataRegister dr (
        .tck_i(tck_i),
        .trst_i(trst_i),
        .shiftDR_i(shiftDR_s),
        .updateDR_i(updateDR_s),
        .tdi_i(tdi_i),
        .drEna_i(enaBSR_s),
        .tdo_o(muxTDO_s), // DR shifts data to tdo_o
        .wEn_o(wEn_o),
        .loadAddr_o(loadAddr_o),
        .loadData_o(loadData_o)
    );
    
    //Bypass register
    pb_bypass bypass(
        .tck_i(tck_i),
        .tdi_i(tdi_i),
        .bypassEna_i(enaBypass_s),
        .tdo_o(muxBypass_s)
    );
    
    //Register MUX
    pb_dr_mux drMux(
        .sel_i(regSel_s),
        .dr_i(muxTDO_s),
        .scan_i(),
        .bypass_i(muxBypass_s),
        .tdo_o(drTDO_s)
    );
    
    //TDO MUX
    pb_tdoMux tdoMux(
        .IR_TDO_i(irTDO_s),
        .DR_TDO_i(drTDO_s),
        .sel_i(selTDO_s),
        .TDO_o(dffTDO_s)
    );

    //TDO DFF
    pb_dff dffTDO(
        .TCK_i(tck_i),
        .TRST_i(trst_i),
        .d_i(dffTDO_s),
        .q_o(clkTDO_s)
    );  
    
    //Enable TDO
    pb_outEna enaTDO(
        .dIn_i(clkTDO_s),
        .ena_i(enaTDO_s),
        .dOut_o(tdo_o)
    );      

endmodule