`timescale 1ns / 1ps

module pb_tb_iMem_bram();

    // Parameters
    parameter int MEM_DEPTH = 64;

    // Testbench signals
    logic test_clk, proc_clk;                // Test clock and processor clock
    logic [5:0] addr_i, loadAddr_i;          // Addresses
    logic [31:0] loadData_i;                 // Data to be written
    logic wEn_i;                             // Write enable
    logic [31:0] data_o;                     // Read data

    // Instantiate the pb_iMem module
    pb_iMem_bram #(MEM_DEPTH) uut (
        .test_clk_i(test_clk),
        .proc_clk_i(proc_clk),
        .addr_i(addr_i),
        .loadAddr_i(loadAddr_i),
        .loadData_i(loadData_i),
        .wEn_i(wEn_i),
        .data_o(data_o)
    );

    // Clock generation
    initial begin
        test_clk = 0;
        forever #5 test_clk = ~test_clk;     // 100 MHz TestClock (10 ns period)
    end

    initial begin
        proc_clk = 0;
        forever #7 proc_clk = ~proc_clk;     // ~71.4 MHz Processor Clock (14 ns period)
    end

    // Test procedure
    initial begin
        // Initialize signals
        wEn_i = 0;
        addr_i = 0;
        loadAddr_i = 0;
        loadData_i = 0;

        // Wait for reset period
        #20;

        // Write data to memory using TestClock
        @(posedge test_clk);
        wEn_i = 1;
        loadAddr_i = 6'd10;
        loadData_i = 32'hDEADBEEF;

        @(posedge test_clk);
        wEn_i = 0; // Disable write after data is written

        // Wait for some cycles to simulate delay
        #30;

        // Read data from memory using Processor Clock
        @(posedge proc_clk);
        addr_i = 6'd10; // Set read address

        @(posedge proc_clk);
        // Assert that the data read matches the data written
        assert(data_o == 32'hDEADBEEF)
            else $fatal("Test failed: Read data mismatch!");

        // Write another value and read it back
        @(posedge test_clk);
        wEn_i = 1;
        loadAddr_i = 6'd20;
        loadData_i = 32'hCAFEBABE;

        @(posedge test_clk);
        wEn_i = 0;

        @(posedge proc_clk);
        addr_i = 6'd20;

        @(posedge proc_clk);
        // Assert that the data read matches the second data written
        assert(data_o == 32'hCAFEBABE)
            else $fatal("Test failed: Second read data mismatch!");

        // Test complete
        $display("All tests passed!");
        $finish;
    end

endmodule
