`timescale 1ns/1ps

module pb_tb_tapcontroller;

    // Inputs
    logic tck_s, tms_s, trst_s;

    // Outputs from updated TAP Controller
    logic shiftIR_s, updateIR_s;
    logic shiftDR_s, updateDR_s;
    logic captureIR_s, captureDR_s;
    logic SelectIR_s;
    logic Enable_s;

    // TAP Instructions (not currently used by the TAPC)
    localparam LOAD_PROGRAM = 4'b0001;
    localparam SCAN_TEST    = 4'b0010;
    localparam BYPASS       = 4'b0011;

    // DUT: Updated TAP Controller
    pb_TAP_Controller tap_ctrl (
        .tck_i(tck_s),
        .tms_i(tms_s),
        .trst_i(trst_s),
        .shiftIR_o(shiftIR_s),
        .updateIR_o(updateIR_s),
        .shiftDR_o(shiftDR_s),
        .updateDR_o(updateDR_s),
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
        trst_s = 1;

        // TEST 1: TAP Reset
        $display("TEST 1: TAP Reset...");
        @(posedge tck_s);
        trst_s = 1; // Assert reset
        tms_s = 1;

        @(posedge tck_s); 
        #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.TEST_LOGIC_RESET)
          else $error("Not in TEST_LOGIC_RESET after reset");
        
        trst_s = 0; // Deassert reset
        tms_s = 1; //Stay in TEST_LOGIC_RESET
        
        @(posedge tck_s); 
        #1; 
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.TEST_LOGIC_RESET)
          else $error("Not in TEST_LOGIC_RESET while holding TMS=1");

        // TEST 2: From TEST_LOGIC_RESET -> RUN_TEST_IDLE
        $display("TEST 2: TAP Reset -> RUN_TEST_IDLE");
        trst_s = 0; 
        tms_s = 0; // Move from RESET to RUN_TEST_IDLE

        @(posedge tck_s);   
        #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.RUN_TEST_IDLE)
          else $error("Not in RUN_TEST_IDLE");

        trst_s = 0; 
        tms_s = 1; // Move to SELECT_DR_SCAN

        @(posedge tck_s);   
        #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SELECT_DR_SCAN)
          else $error("Not in SELECT_DR_SCAN");

        // TEST 3: SELECT_DR_SCAN -> CAPTURE_DR
        // In JTAG, going from SELECT_DR_SCAN with TMS=0 leads to CAPTURE_DR
        
        // TEST 4: CAPTURE_DR -> SHIFT_DR
        $display("TEST 4: CAPTURE_DR -> SHIFT_DR");
        trst_s = 0; 
        tms_s = 0; // staying low moves to SHIFT_DR

        @(posedge tck_s);   
        #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SHIFT_DR)
          else $error("Not in SHIFT_DR");
        assert(shiftDR_s == 1)
          else $error("shiftDR_s not asserted in SHIFT_DR state");
        assert(Enable_s == 1)
          else $error("Enable_s not asserted in SHIFT_DR state");

        // TEST 5: SHIFT_DR -> EXIT1_DR
        $display("TEST 5: SHIFT_DR -> EXIT1_DR");
        trst_s = 0; 
        tms_s = 1; // TMS=1 moves to EXIT1_DR
        
        @(posedge tck_s);   
        #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.EXIT1_DR)
          else $error("Not in EXIT1_DR");

        // TEST 6: EXIT1_DR -> PAUSE_DR
        $display("TEST 6: EXIT1_DR -> PAUSE_DR");
        trst_s = 0; 
        tms_s = 0; // TMS=0 moves to PAUSE_DR

        @(posedge tck_s);   
        #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.PAUSE_DR)
          else $error("Not in PAUSE_DR");

        // TEST 7: PAUSE_DR -> EXIT2_DR -> SHIFT_DR
        $display("TEST 7: PAUSE_DR -> EXIT2_DR -> SHIFT_DR");
        trst_s = 0; 
        tms_s = 1; // moves to EXIT2_DR

        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.EXIT2_DR)
          else $error("Not in EXIT2_DR");

        trst_s = 0; 
        tms_s = 0; // moves back to SHIFT_DR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SHIFT_DR)
          else $error("Not in SHIFT_DR after EXIT2_DR->SHIFT_DR");

        // TEST 8: SHIFT_DR -> EXIT1_DR -> UPDATE_DR -> RUN_TEST_IDLE
        $display("TEST 8: SHIFT_DR -> EXIT1_DR -> UPDATE_DR -> RUN_TEST_IDLE");
        trst_s = 0; 
        tms_s = 1; // SHIFT_DR->EXIT1_DR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.EXIT1_DR)
          else $error("Not in EXIT1_DR from SHIFT_DR");

        tms_s = 1; // EXIT1_DR->UPDATE_DR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.UPDATE_DR)
          else $error("Not in UPDATE_DR from EXIT1_DR");
        assert(updateDR_s == 1)
          else $error("updateDR_s not asserted in UPDATE_DR state");

        tms_s = 0; // UPDATE_DR->RUN_TEST_IDLE
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.RUN_TEST_IDLE)
          else $error("Not in RUN_TEST_IDLE from UPDATE_DR");

        // TEST 9: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> CAPTURE_IR
        $display("TEST 9: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> CAPTURE_IR");
        tms_s = 1; // RUN_TEST_IDLE->SELECT_DR_SCAN
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SELECT_DR_SCAN)
          else $error("Not in SELECT_DR_SCAN from IDLE");

        tms_s = 1; // SELECT_DR_SCAN->SELECT_IR_SCAN
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SELECT_IR_SCAN)
          else $error("Not in SELECT_IR_SCAN");

        // TEST 10: CAPTURE_IR->SHIFT_IR
        $display("TEST 10: CAPTURE_IR -> SHIFT_IR");
        tms_s = 0; // CAPTURE_IR->SHIFT_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SHIFT_IR)
          else $error("Not in SHIFT_IR from CAPTURE_IR");
        assert(shiftIR_s == 1)
          else $error("shiftIR_s not asserted in SHIFT_IR state");
        assert(Enable_s == 1)
          else $error("Enable_s not asserted in SHIFT_IR state");

        // TEST 11: SHIFT_IR -> EXIT1_IR -> PAUSE_IR
        $display("TEST 11: SHIFT_IR -> EXIT1_IR -> PAUSE_IR");
        tms_s = 1; // SHIFT_IR->EXIT1_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.EXIT1_IR)
          else $error("Not in EXIT1_IR from SHIFT_IR");

        tms_s = 0; // EXIT1_IR->PAUSE_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.PAUSE_IR)
          else $error("Not in PAUSE_IR from EXIT1_IR");

        // TEST 12: PAUSE_IR -> EXIT2_IR -> SHIFT_IR
        $display("TEST 12: PAUSE_IR -> EXIT2_IR -> SHIFT_IR");
        tms_s = 1; // PAUSE_IR->EXIT2_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.EXIT2_IR)
          else $error("Not in EXIT2_IR from PAUSE_IR");

        tms_s = 0; // EXIT2_IR->SHIFT_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SHIFT_IR)
          else $error("Not in SHIFT_IR from EXIT2_IR");

        // TEST 13: SHIFT_IR -> EXIT1_IR -> UPDATE_IR -> RUN_TEST_IDLE
        $display("TEST 13: SHIFT_IR -> EXIT1_IR -> UPDATE_IR -> RUN_TEST_IDLE");
        tms_s = 1; // SHIFT_IR->EXIT1_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.EXIT1_IR)
          else $error("Not in EXIT1_IR");

        tms_s = 1; // EXIT1_IR->UPDATE_IR
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.UPDATE_IR)
          else $error("Not in UPDATE_IR");
        assert(updateIR_s == 1)
          else $error("updateIR_s not asserted in UPDATE_IR state");

        tms_s = 0; // UPDATE_IR->RUN_TEST_IDLE
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.RUN_TEST_IDLE)
          else $error("Not in RUN_TEST_IDLE after UPDATE_IR");

        // TEST 14: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> TEST_LOGIC_RESET
        $display("TEST 14: RUN_TEST_IDLE -> SELECT_DR_SCAN -> SELECT_IR_SCAN -> TEST_LOGIC_RESET");
        tms_s = 1; // IDLE->SELECT_DR_SCAN
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SELECT_DR_SCAN)
          else $error("Not in SELECT_DR_SCAN from IDLE");

        tms_s = 1; // SELECT_DR_SCAN->SELECT_IR_SCAN
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.SELECT_IR_SCAN)
          else $error("Not in SELECT_IR_SCAN from SELECT_DR_SCAN");

        tms_s = 1; // SELECT_IR_SCAN->TEST_LOGIC_RESET
        @(posedge tck_s); #1;
        assert(pb_TAP_Controller.currentState == pb_TAP_Controller.TEST_LOGIC_RESET)
          else $error("Not in TEST_LOGIC_RESET from SELECT_IR_SCAN");
        
        #10
        $display("All TAP Controller Tests Passed!");
        $finish;
    end

endmodule
