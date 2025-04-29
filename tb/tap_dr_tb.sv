`timescale 1ns/1ps

module pb_tb_dr;

    // Clock and control signals
    logic tck_s;
    logic tdi_s;
    logic wEn_s;
    logic captureDR_s, shiftDR_s, updateDR_s;
    logic [3:0] irInstr_s;
    logic tdo_s;
    logic [63:0] loadAddr_s;
    logic [31:0] loadData_s;

    // Test data
    localparam logic [63:0] ADDR1 = 64'h0000000000000001; // Test address
    localparam logic [31:0] DATA1 = 32'h00000093;         // Test data (ADDI x1, x0, 0x93)

    // Clock generation
    initial begin
        tck_s = 0;
        forever #5 tck_s = ~tck_s; // 10ns clock period
    end

    // DUT: Data Register
    pb_DataRegister dr (
        .tck_i(tck_s),
        .trst(),
        .captureDR_i(captureDR_s),
        .shiftDR_i(shiftDR_s),
        .updateDR_i(updateDR_s),
        .tdi_i(tdi_s),
        .irInstr_i(irInstr_s),
        .tdo_o(tdo_s),
        .wEn_o(wEn_s),
        .loadAddr_o(loadAddr_s),
        .loadData_o(loadData_s)
    );

    localparam LOAD_PROGRAM = 4'b0001;
    localparam SCAN_TEST    = 4'b0010;
    localparam BYPASS       = 4'b0011;
    // Test logic
    initial begin
        // Initialize control signals
        captureDR_s = 0; shiftDR_s = 0; updateDR_s = 0;
        tdi_s = 0;
        irInstr_s = LOAD_PROGRAM;

        // TEST: Shift and update address and data
        $display("Testing DR: Loading Address and Data...");
        shiftDR_s = 1;
        for (int i = 0; i < 96; i++) begin
            @(posedge tck_s);        
            if (i < 64) tdi_s = ADDR1[i];        // First 64 bits for address
            else        tdi_s = DATA1[i - 64];  // Next 32 bits for data
        end
        @(posedge tck_s);
        shiftDR_s = 0;
        @(posedge tck_s);

        updateDR_s = 1;
        @(posedge tck_s);
        updateDR_s = 0;

        // Assertions
        assert(loadAddr_s == ADDR1) else $fatal("DR Error: Expected Address %h, Got %h", ADDR1, loadAddr_s);
        assert(loadData_s == DATA1) else $fatal("DR Error: Expected Data %h, Got %h", DATA1, loadData_s);

        $display("DR Test Passed: Address = %h, Data = %h", loadAddr_s, loadData_s);

        // Test complete
        $display("Data Register Tests Passed!");
        $finish;
    end

endmodule
