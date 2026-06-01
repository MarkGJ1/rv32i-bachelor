/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 30.04.2025
*/

`timescale 1ns/10ps

module tap_IR_tb;

    // Clock and control signals
    logic tck_s;
    logic tdi_s;
    logic trst_s;
    logic shiftIR_s, updateIR_s;

    // Outputs
    logic [3:0] instruction_s;

    // Clock generation
    initial begin
        tck_s = 0;
        forever #5 tck_s = ~tck_s; // 10ns clock period
    end

    // DUT: Instruction Register
    tap_instruction_register tap_IR (
        .tck_i(tck_s),
        .tdi_i(tdi_s),
        .trst_i(trst_s),
        .shiftIR_i(shiftIR_s),
        .updateIR_i(updateIR_s),
        .instruction_o(instruction_s)
    );

    // Test logic
    initial begin
        // (scale to ns, digits after decimal, time unit suffix, min. field width)
        $timeformat(-9, 2, " ns", 10);
        // Initialize control signals
        tdi_s       = 0;
        shiftIR_s   = 0; 
        updateIR_s  = 0;
        
        $display("RESETTING INSTRUCTION REGISTER; Time %t", $time);
        trst_s      = 0;

        $display("RELEASING RESET; Time %t", $time); 
        @(posedge tck_s)
        trst_s      = 1;

        // TEST 1: Shift and update LOAD_PROGRAM
        $display("Testing IR: Loading LOAD_PROGRAM...");
        shiftIR_s = 1;
        @(posedge tck_s)
        for (int i = 0; i < 4; i++) begin
            tdi_s = LOAD_PROGRAM[i];
            @(posedge tck_s);
        end

        @(posedge tck_s);
        shiftIR_s = 0;
        @(posedge tck_s);

        updateIR_s = 1;
        @(posedge tck_s);
        updateIR_s = 0;

        assert(instruction_s == LOAD_PROGRAM) else $fatal("IR Error: Expected LOAD_PROGRAM (%b), Got %b", LOAD_PROGRAM, instruction_s);
        $display("IR Test Passed: Instruction = LOAD_PROGRAM (%b)", instruction_s);

        // TEST 2: Shift and update SCAN_TEST
        $display("Testing IR: Loading SCAN_TEST...");
        shiftIR_s = 1;
        for (int i = 0; i < 4; i++) begin
            tdi_s = SCAN_TEST[i];
            @(posedge tck_s);
        end

        shiftIR_s = 0;
        @(posedge tck_s);

        updateIR_s = 1;
        @(posedge tck_s);
        updateIR_s = 0;

        assert(instruction_s == SCAN_TEST) else $fatal("IR Error: Expected SCAN_TEST (%b), Got %b", SCAN_TEST, instruction_s);
        $display("IR Test Passed: Instruction = SCAN_TEST (%b)", instruction_s);

        // Test complete
        $display("Instruction Register Tests Passed!");
        $finish;
    end

endmodule
