/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

import pb_pack::*;

module pb_TAP_Controller(
    input  logic tck_i,   // JTAG clock
    input  logic tms_i,   // JTAG mode select
    input  logic trst_i,  // JTAG reset
    output logic shiftIR_o,     updateIR_o,
    output logic shiftDR_o,     updateDR_o,
    output logic SelectIR_o,
    output logic Enable_o
);

    typedef enum logic [3:0] {
        TEST_LOGIC_RESET, RUN_TEST_IDLE,
        SELECT_DR_SCAN, SHIFT_DR, EXIT1_DR, PAUSE_DR, EXIT2_DR, UPDATE_DR,
        SELECT_IR_SCAN, SHIFT_IR, EXIT1_IR, PAUSE_IR, EXIT2_IR, UPDATE_IR
    } state_t;

    state_t currentState, nextState;

    // State Transition Logic
    always_ff @(posedge tck_i or posedge trst_i) begin
        if (trst_i)
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
            SELECT_DR_SCAN:     nextState = tms_i ? SELECT_IR_SCAN   : SHIFT_DR;
            SHIFT_DR:           nextState = tms_i ? EXIT1_DR         : SHIFT_DR;
            EXIT1_DR:           nextState = tms_i ? UPDATE_DR        : PAUSE_DR;
            PAUSE_DR:           nextState = tms_i ? EXIT2_DR         : PAUSE_DR;
            EXIT2_DR:           nextState = tms_i ? UPDATE_DR        : SHIFT_DR;
            UPDATE_DR:          nextState = tms_i ? SELECT_DR_SCAN   : RUN_TEST_IDLE;

            // IR path
            SELECT_IR_SCAN:     nextState = tms_i ? TEST_LOGIC_RESET : SHIFT_IR;
            SHIFT_IR:           nextState = tms_i ? EXIT1_IR         : SHIFT_IR;
            EXIT1_IR:           nextState = tms_i ? UPDATE_IR        : PAUSE_IR;
            PAUSE_IR:           nextState = tms_i ? EXIT2_IR         : PAUSE_IR;
            EXIT2_IR:           nextState = tms_i ? UPDATE_IR        : SHIFT_IR;
            UPDATE_IR:          nextState = tms_i ? SELECT_DR_SCAN   : RUN_TEST_IDLE;

            default:            nextState = TEST_LOGIC_RESET;
        endcase
    end

    // IR/DR selection logic:
    // If we are in IR states (CAPTURE_IR, SHIFT_IR, EXIT1_IR, PAUSE_IR, EXIT2_IR, UPDATE_IR),
    // SelectIR_o = 1, else 0.
    assign SelectIR_o = (currentState == SHIFT_IR  ||
                         currentState == EXIT1_IR   || currentState == PAUSE_IR  ||
                         currentState == EXIT2_IR   || currentState == UPDATE_IR);

    // State-Based Signal Assignments
    assign shiftDR_o   = (currentState == SHIFT_DR);
    assign updateDR_o  = (currentState == UPDATE_DR);

    assign shiftIR_o   = (currentState == SHIFT_IR);
    assign updateIR_o  = (currentState == UPDATE_IR);


    // Enable Output at TDO: Enable when shifting IR or DR
    // The standard JTAG spec typically enables TDO output only during shifting states,
    // but you can adjust as needed.
    always_ff @(negedge tck_i) begin
        Enable_o = (shiftDR_o || shiftIR_o);
    end

endmodule