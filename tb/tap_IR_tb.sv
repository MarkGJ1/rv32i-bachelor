`timescale 1ns/1ps

module pb_tb_ir;

    // Clock and control signals
    logic tck_s;
    logic tdi_s;
    logic shiftIR_s, updateIR_s;

    // Outputs
    logic tdo_s;
    logic [3:0] instruction_s;

    // TAP instructions
    localparam LOAD_PROGRAM = 4'b1000;
    localparam SCAN_TEST    = 4'b0010;

    // Clock generation
    initial begin
        tck_s = 0;
        forever #5 tck_s = ~tck_s; // 10ns clock period
    end

    // DUT: Instruction Register
    pb_InstructionRegister ir (
        .tck_i(tck_s),
        .trst(),
        .shiftIR_i(shiftIR_s),
        .updateIR_i(updateIR_s),
        .tdi_i(tdi_s),
        .tdo_o(tdo_s),
        .instruction_o(instruction_s)
    );

    // Test logic
    initial begin
        // Initialize control signals
        shiftIR_s = 0; updateIR_s = 0;
        tdi_s = 0;

        // TEST 1: Shift and update LOAD_PROGRAM
        $display("Testing IR: Loading LOAD_PROGRAM...");
        shiftIR_s = 1;
        for (int i = 0; i < 4; i++) begin
            @(posedge tck_s);
            tdi_s = LOAD_PROGRAM[i];
            
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
