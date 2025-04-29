`timescale 1ns / 1ps

module pb_tb_tdo_mux;

    // Testbench signals
    logic [1:0] sel_i;       // Selection input
    logic dr_i;              // Data Register input
    logic scan_i;            // Scan Chain input
    logic bypass_i;          // Bypass input
    logic tdo_o;             // TDO output

    // Instantiate the DUT (pb_tdo_mux)
    pb_dr_mux dut (
        .sel_i(sel_i),
        .dr_i(dr_i),
        .scan_i(scan_i),
        .bypass_i(bypass_i),
        .tdo_o(tdo_o)
    );

    // Stimulus
    initial begin
        $display("Starting pb_dr_mux Testbench...");

        // Test case 1: sel_i = 2'b01 (Select DR input)
        sel_i = 2'b01;
        dr_i = 1; scan_i = 0; bypass_i = 0;
        #1; // Small delay for combinational logic
        assert(tdo_o == dr_i) else $fatal("Test failed for sel_i = 2'b01. Expected: %b, Got: %b", dr_i, tdo_o);
        $display("Test passed for sel_i = 2'b01: TDO = %b", tdo_o);
        sel_i = 2'b01;
        dr_i = 0; scan_i = 0; bypass_i = 0;
        #1; // Small delay for combinational logic
        assert(tdo_o == dr_i) else $fatal("Test failed for sel_i = 2'b01. Expected: %b, Got: %b", dr_i, tdo_o);
        $display("Test passed for sel_i = 2'b01: TDO = %b", tdo_o);

        // Test case 2: sel_i = 2'b10 (Select Scan input)
        sel_i = 2'b10;
        dr_i = 0; scan_i = 1; bypass_i = 0;
        #1; // Small delay for combinational logic
        assert(tdo_o == scan_i) else $fatal("Test failed for sel_i = 2'b10. Expected: %b, Got: %b", scan_i, tdo_o);
        $display("Test passed for sel_i = 2'b10: TDO = %b", tdo_o);
        sel_i = 2'b10;
        dr_i = 0; scan_i = 0; bypass_i = 0;
        #1; // Small delay for combinational logic
        assert(tdo_o == scan_i) else $fatal("Test failed for sel_i = 2'b10. Expected: %b, Got: %b", scan_i, tdo_o);
        $display("Test passed for sel_i = 2'b10: TDO = %b", tdo_o);

        // Test case 3: sel_i = 2'b11 (Select Bypass input)
        sel_i = 2'b11;
        dr_i = 0; scan_i = 0; bypass_i = 1;
        #1; // Small delay for combinational logic
        assert(tdo_o == bypass_i) else $fatal("Test failed for sel_i = 2'b11. Expected: %b, Got: %b", bypass_i, tdo_o);
        $display("Test passed for sel_i = 2'b11: TDO = %b", tdo_o);
        sel_i = 2'b11;
        dr_i = 0; scan_i = 0; bypass_i = 0;
        #1; // Small delay for combinational logic
        assert(tdo_o == bypass_i) else $fatal("Test failed for sel_i = 2'b11. Expected: %b, Got: %b", bypass_i, tdo_o);
        $display("Test passed for sel_i = 2'b11: TDO = %b", tdo_o);

        // Test case 4: sel_i = 2'b00 (Default case, select Bypass input)
        sel_i = 2'b00;
        dr_i = 1; scan_i = 1; bypass_i = 1;
        #1; // Small delay for combinational logic
        assert(tdo_o == 0) else $fatal("Test failed for sel_i = 2'b00 (default). Expected: %b, Got: %b", bypass_i, tdo_o);
        $display("Test passed for sel_i = 2'b00 (default): TDO = %b", tdo_o);

        $display("All tests passed successfully!");
        $finish;
    end

endmodule