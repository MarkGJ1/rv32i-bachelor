/*
    File name: tap_bsr.sv
    Description: TODO: Include your internal logic and your boundary scan cells connected to it.
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

import pkg_config::*;

module tap_bs_register (
    input logic tdi_i,
    input logic [9:0] in_i, // THIS IS DATA IN, NOT EXACTLY TDI! CAPTUREDR TAKES IN NORMAL DATA FROM INTERNAL LOGIC
    input logic clockDR, shiftDR, updateDR,
    input logic mode_i,
    output logic [INST_WIDTH-1:0] out_o,
    output logic tdo_o
);

    logic [10:0]            bscan_addr_shift_chain; // 11 wires: 10 cells + tdi input.
    logic [32:0]            bscan_inst_shift_chain; // 33 wires: 32 cells + tdo output.
    logic [9:0]             bscan_addr_bit; // 10-bit register for 10 bscan_cells for addr_i.
    logic [INST_WIDTH-1:0]  bscan_inst_out; // 32-bit register for 32 bscan_cells for inst_o.

    assign bscan_addr_shift_chain[0] = tdi_i;
    assign bscan_inst_shift_chain[0] = bscan_addr_shift_chain[10];
    assign tdo_o                     = bscan_inst_shift_chain[32];

    instruction_memory dut (
        .addr_i(bscan_addr_bit),
        .inst_o(bscan_inst_out)
    );

    // Instantiate all scan cells connected to input of instruction memory.
    genvar i;
    generate
        for (i = 0; i < 10; i++) begin : gen_bscan_cells_addr
            tap_bs_cell bscan_cell_addr(
                .in_i(in_i[i]),
                .si_i(bscan_addr_shift_chain[i]),
                .clockDR(clockDR),
                .shiftDR(shiftDR),
                .updateDR(updateDR),
                .mode_i(mode_i),
                .so_o(bscan_addr_shift_chain[i+1]),
                .out_o(bscan_addr_bit[i])
            );
        end
    endgenerate

    // Instantiate all scan cells connected to input of instruction memory.
    genvar j;
    generate
        for (j = 0; j < 32; j++) begin : gen_bscan_cells_inst
            tap_bs_cell bscan_cell_inst(
                .in_i(bscan_inst_out[j]),
                .si_i(bscan_inst_shift_chain[j]),
                .clockDR(clockDR),
                .shiftDR(shiftDR),
                .updateDR(updateDR),
                .mode_i(mode_i),
                .so_o(bscan_inst_shift_chain[j+1]),
                .out_o(out_o[i])
            );
        end
    endgenerate

endmodule