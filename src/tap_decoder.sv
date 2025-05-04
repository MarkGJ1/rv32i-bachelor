/*
    File name: tap_IRDecoder.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

`timescale 1ns / 10ps

import tap_pkg::*; // Import the package that defines instructions and widths

module tap_instruction_decoder (
    input  logic [instruction_width-1:0] irInstruction_i,
    output logic scanEnable_o,
    output logic bypassEnable_o,
    output logic dataReg_sel,
    output logic extest_mode_o,
    output logic sample_mode_o,
    output logic preload_mode_o
);

    always_comb begin
        // Default values
        scanEnable_o   = 1'b0;
        bypassEnable_o = 1'b0;
        dataReg_sel    = 1'b0;  // Default to BYPASS
        extest_mode_o  = 1'b0;
        sample_mode_o  = 1'b0;
        preload_mode_o = 1'b0;

        unique case (irInstruction_i)
            EXTEST: begin
                scanEnable_o   = 1'b1;
                bypassEnable_o = 1'b0;
                dataReg_sel          = 2'b01;   // Select BSR
                extest_mode_o  = 1'b1;    // EXTEST active
            end

            SAMPLE: begin
                scanEnable_o   = 1'b1;
                bypassEnable_o = 1'b0;
                dataReg_sel          = 2'b01;   // Select BSR
                sample_mode_o  = 1'b1;    // SAMPLE active
            end

            PRELOAD: begin
                scanEnable_o   = 1'b1;
                bypassEnable_o = 1'b0;
                dataReg_sel          = 2'b01;   // Select BSR
                preload_mode_o = 1'b1;    // PRELOAD active
            end
            
            BYPASS: begin
                scanEnable_o   = 1'b0;
                bypassEnable_o = 1'b1;
                dataReg_sel          = 2'b11;   // Select BYPASS
                // All mode signals remain 0 since BYPASS doesn't involve BSR modes
            end

            default: begin
                // Unknown instructions also map to BYPASS
                scanEnable_o   = 1'b0;
                bypassEnable_o = 1'b1;
                dataReg_sel          = 2'b11;   // Select BYPASS
                // All mode signals remain 0
            end
        endcase
    end

endmodule