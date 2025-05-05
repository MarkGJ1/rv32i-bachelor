/*
    File name: tap_bs_cell_tb.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

`timescale 1ns/10ps

module tap_bs_cell_tb;

    // Inputs
    logic tck_s; // USED IN ClockDR!!!
    logic trst_s;
    logic [1:0] in_s    = '0;
    logic si_s          = 0;
    logic SAMPLE_s      = 0, PRELOAD_s = 0;
    logic clockDR_s;
    logic shiftDR_s     = 0;
    logic updateDR_s    = 0;
    logic mode_s        = 0;

    // Outputs
    logic so_s          = 0;
    logic [1:0] out_s   = '0;
    logic so_last_s     = 0;

    // Test logic
    logic [7:0] testData_s = 8'b0000_0000;

    // Clock enabler
    logic enaCLK_s      = 1;

    // Outputs from updated TAP Controller
    tap_bs_cell tap_cell1(
        .trst_i(trst_s),
        .in_i(in_s[0]),
        .si_i(si_s),
        .SAMPLE_i(SAMPLE_s),
        .PRELOAD_i(PRELOAD_s),
        .clockDR_i(clockDR_s),
        .shiftDR_i(shiftDR_s),
        .updateDR_i(updateDR_s),
        .mode_i(mode_s),
        .so_o(so_s),
        .out_o(out_s[0])
    );

    tap_bs_cell tap_cell2(
        .trst_i(trst_s),
        .in_i(in_s[1]),
        .si_i(so_s),
        .SAMPLE_i(SAMPLE_s),
        .PRELOAD_i(PRELOAD_s),
        .clockDR_i(clockDR_s),
        .shiftDR_i(shiftDR_s),
        .updateDR_i(updateDR_s),
        .mode_i(mode_s),
        .so_o(so_last_s),
        .out_o(out_s[1])
    );

    // Clock generation
    initial begin
        tck_s = 0;
        forever #5 tck_s = ~tck_s; // 10ns clock period
    end

    assign clockDR_s = enaCLK_s ? tck_s : 0;

    initial begin
        // (scale to ns, digits after decimal, time unit suffix, min. field width)
        $timeformat(-9, 2, " ns", 10);
        
        // Reset all registers.
        $display("1. RESETTING ALL REGISTERS; Time %t", $time);
        @(posedge tck_s)
        trst_s = 0;

        // Assert reset is correct.
        @(posedge tck_s)
        assert (so_s        == 0) else $fatal (1,"so_o != 0 at time: %t", $time);
        assert (so_last_s   == 0) else $fatal (1,"so_o != 0 at time: %t", $time);
        assert (out_s[0]    == 0) else $fatal (1,"so_o != 0 at time: %t", $time);
        assert (out_s[1]    == 0) else $fatal (1,"so_o != 0 at time: %t", $time);
        $display("Test pass!");

        // Release from reset state.
        @(posedge tck_s);
        $display("2. RELEASE FROM RESET; Time %t", $time);
        trst_s = 1;

        // Performing SAMPLE operation.
        $display("3. PERFORMING SAMPLE OPERATION; Time %t", $time);
        @(posedge tck_s)
        mode_s      = 0;
        SAMPLE_s    = 1;
        shiftDR_s   = 0;
        in_s[0]     = 1;
        in_s[1]     = 1;

        @(posedge tck_s)
        assert (so_s        == 1) else $fatal (1,"so_s != 1 at time: %t", $time);
        assert (so_last_s   == 1) else $fatal (1,"so_last_s != 1 at time: %t", $time);
        assert (tap_cell1.r1_reg == 1) else $fatal (1,"tap_cell1.r1_reg != 1 at time: %t", $time);
        assert (out_s[0]    == 1) else $fatal (1,"out_s[0] != 1 at time: %t", $time);
        assert (out_s[1]    == 1) else $fatal (1,"out_s[1] != 1 at time: %t", $time);
        $display("Test pass!");

        // Performing PRELOAD operation.
        $display("4. PERFORMING PRELOAD OPERATION; Time %t", $time);
        @(posedge tck_s)
        // I could have just reset?
        mode_s      = 1; // out_o = r2_reg;
        SAMPLE_s    = 0;
        shiftDR_s   = 1;
        PRELOAD_s   = 1;
        in_s[0]     = 1;
        in_s[1]     = 0;
        testData_s  = 8'b1010_1111;

        // Visible gap in simulation
        @(posedge tck_s)
        @(posedge tck_s)
        @(posedge tck_s)
        @(posedge tck_s)

        // Extra loop?
        for(int i = 0; i < 8; i++) begin
            si_s = testData_s[i];
            @(posedge tck_s);
            $display("si_s = %b at time %t", testData_s[i], $time);
            //@(posedge tck_s)
            //assert (so_s        == testData_s[i]) else $fatal (1,"so_o != 1 at time: %t", $time);
            //assert (so_last_s   == testData_s[i]) else $fatal (1,"so_o != 1 at time: %t", $time);
        end
        
        // PRELOAD second part: updating r2_reg.
        $display("4.1. PERFORMING PRELOAD OPERATION: Updating r2_reg; Time %t", $time);
        // Important to mimic TAP_CONTROLLER outputs from states.
        // Clock needs to be disabled here.
        shiftDR_s   = 0;
        enaCLK_s    = 0;
        @(posedge tck_s)

        // Clock needs to be enabled here for 1 cycle.
        updateDR_s  = 1;
        enaCLK_s    = 1;
        @(posedge tck_s)

        @(negedge tck_s)
        assert (out_s[0]    == testData_s[7]) else $fatal (1,"out_s[0] != testData_s[7] at time: %t", $time);
        assert (out_s[1]    == testData_s[6]) else $fatal (1,"out_s[1] != testData_s[6] at time: %t", $time);

        @(posedge tck_s)
        updateDR_s  = 0;

        // Visible gap in simulation
        @(posedge tck_s)
        @(posedge tck_s)
        @(posedge tck_s)
        @(posedge tck_s)

        // At for loop end, BS cells should hold MSBs from testdata.
        assert (so_s        == testData_s[7]) else $fatal (1,"so_s      != testData_s[7] at time: %t", $time);
        assert (so_last_s   == testData_s[6]) else $fatal (1,"so_last_s != testData_s[6] at time: %t", $time);
        $display("Test pass!");

        //@(negedge tck_s) // Updates on negative clock edge + TAP Controller will go into update state for PRELOAD, no need to worry.
        //assert (out_s[0]    == testData_s[7]) else $fatal (1,"out_s[0] != testData_s[7] at time: %t", $time);
        //assert (out_s[1]    == testData_s[6]) else $fatal (1,"out_s[1] != testData_s[6] at time: %t", $time);

        #10ns;
        $display("All boundary cell tests passed!");
        $finish;
    end

endmodule