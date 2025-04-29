`timescale 1ns / 1ps
import pb_pack::*;

module pb_tb_ir_decoder;

    // Signals
    logic [instruction_width-1:0] irInstruction_s;
    logic scanEnable_s;
    logic bypassEnable_s;
    logic [1:0] mux_s;
    logic extest_mode_s;
    logic sample_mode_s;
    logic preload_mode_s;

    // DUT
    pb_IR_Decoder dut (
        .irInstruction_i(irInstruction_s),
        .scanEnable_s(scanEnable_s),
        .bypassEnable_s(bypassEnable_s),
        .mux_s(mux_s),
        .extest_mode_s(extest_mode_s),
        .sample_mode_s(sample_mode_s),
        .preload_mode_s(preload_mode_s)
    );

    // A test instruction that is not defined in pb_pack for unknown case
    localparam [instruction_width-1:0] UNKNOWN = 4'b0101; 

    initial begin
        $display("Starting IR Decoder Test...");

        // Test EXTEST
        irInstruction_s = EXTEST;
        #10;
        assert(scanEnable_s == 1 && bypassEnable_s == 0 && mux_s == 2'b00 &&
               extest_mode_s == 1 && sample_mode_s == 0 && preload_mode_s == 0)
            else $error("EXTEST decoding incorrect. Got scanEnable=%b, bypassEnable=%b, mux=%b, extest=%b, sample=%b, preload=%b", 
                         scanEnable_s, bypassEnable_s, mux_s, extest_mode_s, sample_mode_s, preload_mode_s);
        $display("EXTEST Passed.");

        // Test SAMPLE
        irInstruction_s = SAMPLE;
        #10;
        assert(scanEnable_s == 1 && bypassEnable_s == 0 && mux_s == 2'b00 &&
               extest_mode_s == 0 && sample_mode_s == 1 && preload_mode_s == 0)
            else $error("SAMPLE decoding incorrect. Got scanEnable=%b, bypassEnable=%b, mux=%b, extest=%b, sample=%b, preload=%b", 
                         scanEnable_s, bypassEnable_s, mux_s, extest_mode_s, sample_mode_s, preload_mode_s);
        $display("SAMPLE Passed.");

        // Test PRELOAD
        irInstruction_s = PRELOAD;
        #10;
        assert(scanEnable_s == 1 && bypassEnable_s == 0 && mux_s == 2'b00 &&
               extest_mode_s == 0 && sample_mode_s == 0 && preload_mode_s == 1)
            else $error("PRELOAD decoding incorrect. Got scanEnable=%b, bypassEnable=%b, mux=%b, extest=%b, sample=%b, preload=%b",
                         scanEnable_s, bypassEnable_s, mux_s, extest_mode_s, sample_mode_s, preload_mode_s);
        $display("PRELOAD Passed.");

        // Test BYPASS
        irInstruction_s = BYPASS;
        #10;
        assert(scanEnable_s == 0 && bypassEnable_s == 1 && mux_s == 2'b11 &&
               extest_mode_s == 0 && sample_mode_s == 0 && preload_mode_s == 0)
            else $error("BYPASS decoding incorrect. Got scanEnable=%b, bypassEnable=%b, mux=%b, extest=%b, sample=%b, preload=%b", 
                         scanEnable_s, bypassEnable_s, mux_s, extest_mode_s, sample_mode_s, preload_mode_s);
        $display("BYPASS Passed.");

        // Test UNKNOWN Instruction (maps to BYPASS)
        irInstruction_s = UNKNOWN;
        #10;
        assert(scanEnable_s == 0 && bypassEnable_s == 1 && mux_s == 2'b11 &&
               extest_mode_s == 0 && sample_mode_s == 0 && preload_mode_s == 0)
            else $error("UNKNOWN decoding incorrect. Expected BYPASS mode. Got scanEnable=%b, bypassEnable=%b, mux=%b, extest=%b, sample=%b, preload=%b", 
                         scanEnable_s, bypassEnable_s, mux_s, extest_mode_s, sample_mode_s, preload_mode_s);
        $display("UNKNOWN Passed (mapped to BYPASS).");

        $display("All IR Decoder Tests Passed!");
        $finish;
    end

endmodule
