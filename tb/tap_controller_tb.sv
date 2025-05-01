/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 30.04.2025
*/

`timescale 1ns/10ps

module tap_controller_tb;

    // Inputs
    logic tck_s, tms_s, trst_s;

    // Outputs from updated TAP Controller
    logic shiftIR_s, updateIR_s;
    logic shiftDR_s, updateDR_s;
    logic clockIR_s, clockDR_s;
    logic SelectIR_s;
    logic Enable_s;

    // TAP Instructions (not currently used by the TAPC)
    // localparam LOAD_PROGRAM = 4'b0001;
    // localparam SCAN_TEST    = 4'b0010;
    // localparam BYPASS       = 4'b0011;

    // DUT: Updated TAP Controller
    tap_controller tap_ctrl (
        .tck_i(tck_s),
        .tms_i(tms_s),
        .trst_i(trst_s),
        .shiftIR_o(shiftIR_s),
        .updateIR_o(updateIR_s),
        .clockIR_o(clockIR_s),
        .shiftDR_o(shiftDR_s),
        .updateDR_o(updateDR_s),
        .clockDR_o(clockDR_s),
        .SelectIR_o(SelectIR_s),
        .Enable_o(Enable_s)
    );

    // Clock generation
    initial begin
        tck_s = 0;
        forever #5 tck_s = ~tck_s; // 10ns clock period
    end

    // Test logic
    initial begin
        // Initialize inputs
        tms_s = 0;
        trst_s = 0;

        // TEST 1: TAP Reset
        $display("TEST 1: TAP Reset... at time: %0t", $time);
        @(posedge tck_s);
        trst_s = 0;
        tms_s = 1;

        @(posedge tck_s); 
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.TEST_LOGIC_RESET)
          else $error("Not in TEST_LOGIC_RESET after reset at time: %0t", $time);
        
        trst_s = 1; // Deassert reset
        tms_s = 1; //Stay in TEST_LOGIC_RESET
        
        @(posedge tck_s); 
        #1; 
        assert(tap_ctrl.currentState == tap_ctrl.TEST_LOGIC_RESET)
          else $error("Not in TEST_LOGIC_RESET while holding TMS=1 at time: %0t", $time);

        // TEST 2: From TEST_LOGIC_RESET -> RUN_TEST_IDLE
        $display("TEST 2: TAP Reset -> RUN_TEST_IDLE at time: %0t", $time);
        tms_s = 0; // Move from RESET to RUN_TEST_IDLE

        @(posedge tck_s);   
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.RUN_TEST_IDLE)
          else $error("Not in RUN_TEST_IDLE at time: %0t", $time);

        tms_s = 1; // Move to SELECT_DR_SCAN

        @(posedge tck_s);   
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.SELECT_DR_SCAN)
          else $error("Not in SELECT_DR_SCAN at time: %0t", $time);

        // TEST 3: SELECT_DR_SCAN -> CAPTURE_DR
        $display("TEST 3: SELECT_DR_SCAN -> CAPTURE_DR at time: %0t", $time);
        tms_s = 0;

        @(posedge tck_s);
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.CAPTURE_DR)
          else $error("Not in CAPTURE_DR at time: %0t", $time);
        // In JTAG, going from SELECT_DR_SCAN with TMS=0 leads to CAPTURE_DR
        
        // TEST 4: CAPTURE_DR -> SHIFT_DR
        $display("TEST 4: CAPTURE_DR -> SHIFT_DR at time: %0t", $time);
        tms_s = 0; // staying low moves to SHIFT_DR

        @(posedge tck_s);   
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.SHIFT_DR)
          else $error("Not in SHIFT_DR at time: %0t", $time);
        assert(shiftDR_s == 1)
          else $error("shiftDR_s not asserted in SHIFT_DR state at time: %0t", $time);
        
        @(negedge tck_s)
        #1;
        assert(Enable_s == 1)
          else $error("Enable_s not asserted in SHIFT_DR state at time: %0t", $time);

        // TEST 5: SHIFT_DR -> EXIT1_DR
        $display("TEST 5: SHIFT_DR -> EXIT1_DR at time: %0t", $time);
        tms_s = 1; // TMS=1 moves to EXIT1_DR
        
        @(posedge tck_s);   
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.EXIT1_DR)
          else $error("Not in EXIT1_DR at time: %0t", $time);

        // TEST 6: EXIT1_DR -> PAUSE_DR
        $display("TEST 6: EXIT1_DR -> PAUSE_DR at time: %0t", $time);
        tms_s = 0; // TMS=0 moves to PAUSE_DR

        @(posedge tck_s);   
        #1;
        assert(tap_ctrl.currentState == tap_ctrl.PAUSE_DR)
          else $error("Not in PAUSE_DR at time: %0t", $time);

        // TEST 7: PAUSE_DR -> EXIT2_DR -> SHIFT_DR
        $display("TEST 7: PAUSE_DR -> EXIT2_DR -> SHIFT_DR at time: %0t", $time);
        tms_s = 1; // moves to EXIT2_DR

        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.EXIT2_DR)
          else $error("Not in EXIT2_DR at time: %0t", $time);

        tms_s = 0; // moves back to SHIFT_DR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SHIFT_DR)
          else $error("Not in SHIFT_DR after EXIT2_DR->SHIFT_DR at time: %0t", $time);

        // Three clock edges used to check for clockDR taking JTAG clock.
        @(posedge tck_s)
        @(posedge tck_s)
        @(posedge tck_s)

        // TEST 8: SHIFT_DR -> EXIT1_DR -> UPDATE_DR -> RUN_TEST_IDLE
        $display("TEST 8: SHIFT_DR -> EXIT1_DR -> UPDATE_DR -> RUN_TEST_IDLE at time: %0t", $time);
        tms_s = 1; // SHIFT_DR->EXIT1_DR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.EXIT1_DR)
          else $error("Not in EXIT1_DR from SHIFT_DR at time: %0t", $time);

        tms_s = 1; // EXIT1_DR->UPDATE_DR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.UPDATE_DR)
          else $error("Not in UPDATE_DR from EXIT1_DR at time: %0t", $time);
        assert(updateDR_s == 1)
          else $error("updateDR_s not asserted in UPDATE_DR state at time: %0t", $time);

        tms_s = 0; // UPDATE_DR->RUN_TEST_IDLE
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.RUN_TEST_IDLE)
          else $error("Not in RUN_TEST_IDLE from UPDATE_DR at time: %0t", $time);

        // TEST 9: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> CAPTURE_IR
        $display("TEST 9: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> CAPTURE_IR at time: %0t", $time);
        tms_s = 1; // RUN_TEST_IDLE->SELECT_DR_SCAN
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SELECT_DR_SCAN)
          else $error("Not in SELECT_DR_SCAN from IDLE at time: %0t", $time);

        tms_s = 1; // SELECT_DR_SCAN->SELECT_IR_SCAN
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SELECT_IR_SCAN)
          else $error("Not in SELECT_IR_SCAN at time: %0t", $time);

        // TEST 10: CAPTURE_IR->SHIFT_IR
        $display("TEST 10: CAPTURE_IR -> SHIFT_IR at time: %0t", $time);
        tms_s = 0; // CAPTURE_IR->SHIFT_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SHIFT_IR)
          else $error("Not in SHIFT_IR from CAPTURE_IR at time: %0t", $time);
        assert(shiftIR_s == 1)
          else $error("shiftIR_s not asserted in SHIFT_IR state at time: %0t", $time);

        @(negedge tck_s)
        #1;
        assert(Enable_s == 1)
          else $error("Enable_s not asserted in SHIFT_IR state at time: %0t", $time);

        // TEST 11: SHIFT_IR -> EXIT1_IR -> PAUSE_IR
        $display("TEST 11: SHIFT_IR -> EXIT1_IR -> PAUSE_IR at time: %0t", $time);
        tms_s = 1; // SHIFT_IR->EXIT1_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.EXIT1_IR)
          else $error("Not in EXIT1_IR from SHIFT_IR at time: %0t", $time);

        tms_s = 0; // EXIT1_IR->PAUSE_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.PAUSE_IR)
          else $error("Not in PAUSE_IR from EXIT1_IR at time: %0t", $time);

        // TEST 12: PAUSE_IR -> EXIT2_IR -> SHIFT_IR
        $display("TEST 12: PAUSE_IR -> EXIT2_IR -> SHIFT_IR at time: %0t", $time);
        tms_s = 1; // PAUSE_IR->EXIT2_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.EXIT2_IR)
          else $error("Not in EXIT2_IR from PAUSE_IR at time: %0t", $time);

        tms_s = 0; // EXIT2_IR->SHIFT_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SHIFT_IR)
          else $error("Not in SHIFT_IR from EXIT2_IR at time: %0t", $time);

        // TEST 13: SHIFT_IR -> EXIT1_IR -> UPDATE_IR -> RUN_TEST_IDLE
        $display("TEST 13: SHIFT_IR -> EXIT1_IR -> UPDATE_IR -> RUN_TEST_IDLE at time: %0t", $time);
        tms_s = 1; // SHIFT_IR->EXIT1_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.EXIT1_IR)
          else $error("Not in EXIT1_IR at time: %0t", $time);

        tms_s = 1; // EXIT1_IR->UPDATE_IR
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.UPDATE_IR)
          else $error("Not in UPDATE_IR at time: %0t", $time);
        assert(updateIR_s == 1)
          else $error("updateIR_s not asserted in UPDATE_IR state at time: %0t", $time);

        tms_s = 0; // UPDATE_IR->RUN_TEST_IDLE
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.RUN_TEST_IDLE)
          else $error("Not in RUN_TEST_IDLE after UPDATE_IR at time: %0t", $time);

        // TEST 14: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> TEST_LOGIC_RESET
        $display("TEST 14: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> TEST_LOGIC_RESET at time: %0t", $time);
        tms_s = 1; // IDLE->SELECT_DR_SCAN
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SELECT_DR_SCAN)
          else $error("Not in SELECT_DR_SCAN from IDLE at time: %0t", $time);

        tms_s = 1; // SELECT_DR_SCAN->SELECT_IR_SCAN
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.SELECT_IR_SCAN)
          else $error("Not in SELECT_IR_SCAN from SELECT_DR_SCAN at time: %0t", $time);

        tms_s = 1; // SELECT_IR_SCAN->TEST_LOGIC_RESET
        @(posedge tck_s); #1;
        assert(tap_ctrl.currentState == tap_ctrl.TEST_LOGIC_RESET)
          else $error("Not in TEST_LOGIC_RESET from SELECT_IR_SCAN at time: %0t", $time);
        
        #10
        $display("All TAP Controller Tests Passed!");
        $finish;
    end

endmodule
