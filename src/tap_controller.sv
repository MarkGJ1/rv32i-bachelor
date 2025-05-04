/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

`timescale 1ns/10ps

import tap_pkg::*;

module tap_controller(
    input  logic tck_i,   // JTAG clock
    input  logic tms_i,   // JTAG mode select
    input  logic trst_i,  // JTAG reset
    output logic shiftIR_o, updateIR_o, clockIR_o,
    output logic shiftDR_o, updateDR_o, clockDR_o,
    output logic SelectIR_o,
    output logic Enable_o,
    output logic rst_o
);

    typedef enum logic [3:0] {
        TEST_LOGIC_RESET, RUN_TEST_IDLE,
        SELECT_DR_SCAN, CAPTURE_DR, SHIFT_DR, EXIT1_DR, PAUSE_DR, EXIT2_DR, UPDATE_DR,
        SELECT_IR_SCAN, CAPTURE_IR, SHIFT_IR, EXIT1_IR, PAUSE_IR, EXIT2_IR, UPDATE_IR
    } state_t;

    state_t currentState, nextState;

    // State Transition Logic
    always_ff @(posedge tck_i or negedge trst_i) begin
        if (!trst_i) 
            currentState <= TEST_LOGIC_RESET;
        else 
            currentState <= nextState;
    end

    always_comb begin
        nextState = currentState; // Default: remain in the same state
        case (currentState)
            TEST_LOGIC_RESET:   nextState = tms_i ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
            RUN_TEST_IDLE:      nextState = tms_i ? SELECT_DR_SCAN   : RUN_TEST_IDLE;

            // DR path
            SELECT_DR_SCAN:     nextState = tms_i ? SELECT_IR_SCAN   : CAPTURE_DR;
            CAPTURE_DR:         nextState = tms_i ? EXIT1_DR         : SHIFT_DR;
            SHIFT_DR:           nextState = tms_i ? EXIT1_DR         : SHIFT_DR;
            EXIT1_DR:           nextState = tms_i ? UPDATE_DR        : PAUSE_DR;
            PAUSE_DR:           nextState = tms_i ? EXIT2_DR         : PAUSE_DR;
            EXIT2_DR:           nextState = tms_i ? UPDATE_DR        : SHIFT_DR;
            UPDATE_DR:          nextState = tms_i ? SELECT_DR_SCAN   : RUN_TEST_IDLE;

            // IR path
            SELECT_IR_SCAN:     nextState = tms_i ? TEST_LOGIC_RESET : CAPTURE_IR;
            CAPTURE_IR:         nextState = tms_i ? EXIT1_IR         : SHIFT_IR;
            SHIFT_IR:           nextState = tms_i ? EXIT1_IR         : SHIFT_IR;
            EXIT1_IR:           nextState = tms_i ? UPDATE_IR        : PAUSE_IR;
            PAUSE_IR:           nextState = tms_i ? EXIT2_IR         : PAUSE_IR;
            EXIT2_IR:           nextState = tms_i ? UPDATE_IR        : SHIFT_IR;
            UPDATE_IR:          nextState = tms_i ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
            default:            nextState = TEST_LOGIC_RESET;
        endcase
    end

    always_comb begin
        // Data-reg control signals
        clockDR_o   = 0;    
        shiftDR_o   = 0;
        updateDR_o  = 0;
        // Instruction-reg control signals
        SelectIR_o  = 0;
        clockIR_o   = 0;
        shiftIR_o   = 0;
        updateIR_o  = 0;

        case (currentState)
            // DR path
            CAPTURE_DR: clockDR_o = tck_i;
            SHIFT_DR:   begin 
                        shiftDR_o = 1;
                        clockDR_o = tck_i;
            end
            EXIT1_DR:   begin   
                        shiftDR_o = 0;
                        clockDR_o = 0;
            end
            UPDATE_DR:  updateDR_o = 1;
            // IR path
            CAPTURE_IR: clockIR_o  = tck_i;
            SHIFT_IR:   begin
                        SelectIR_o = 1;
                        shiftIR_o  = 1;
                        clockIR_o  = tck_i;
            end
            EXIT1_IR:   begin
                        SelectIR_o = 1;
                        shiftIR_o  = 0;
                        clockIR_o  = 0;
            end
            PAUSE_IR:   SelectIR_o = 1;
            EXIT2_IR:   SelectIR_o = 1;
            UPDATE_IR:  begin
                        SelectIR_o = 1;
                        updateIR_o = 1;
            end
        endcase
    end

    // Enable Output at TDO: Enable when shifting IR or DR
    // The standard JTAG spec typically enables TDO output only during shifting states,
    // but you can adjust as needed.
    always_ff @(negedge tck_i) begin
        Enable_o = (shiftDR_o || shiftIR_o);
    end

endmodule