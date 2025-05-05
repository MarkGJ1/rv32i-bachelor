/*
    File name: tap_bsc.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

module tap_bs_cell (
    input logic trst_i,
    input logic in_i, // THIS IS DATA IN, NOT EXACTLY TDI! CaptureDR TAKES IN NORMAL DATA FROM INTERNAL LOGIC
    input logic si_i,
    input logic SAMPLE_i, PRELOAD_i, // Make sure decoder updates mode_i.
    input logic clockDR_i, shiftDR_i, updateDR_i, // tck_i == clockDR_i
    input logic mode_i, // 1 = PRELOAD; 0 = SAMPLE 
    output logic so_o,
    output logic out_o
);

    logic r1_reg, r2_reg;

    always_ff @(posedge clockDR_i or negedge trst_i) begin // CaptureDR is important for output bscan_cells when using SAMPLE function.
        if (!trst_i)
            r1_reg <= 0;
        else if (SAMPLE_i || PRELOAD_i)
            r1_reg <= shiftDR_i ? si_i : in_i;
    end
    
    always_ff @(negedge clockDR_i or negedge trst_i) begin // Update r2_reg.
        if (!trst_i)
            r2_reg <= 0;
        else if (PRELOAD_i && updateDR_i)
            r2_reg <= r1_reg;
    end

    assign so_o  = r1_reg;
    assign out_o = mode_i ? r2_reg : in_i;

endmodule
