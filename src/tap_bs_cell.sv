/*
    File name: tap_bsc.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 25.04.2025
*/

module tap_bs_cell (
    input logic tck_i,
    input logic in_i, // THIS IS DATA IN, NOT EXACTLY TDI! CaptureDR TAKES IN NORMAL DATA FROM INTERNAL LOGIC
    input logic si_i,
    input logic clockDR, shiftDR, updateDR,
    input logic mode_i,
    output logic so_o,
    output logic out_o
);

    logic r1_reg, r2_reg;

    always_ff @(posedge clockDR) begin // CaptureDR is important for output bscan_cells when using SAMPLE function.
        r1_reg <= shiftDR ? si_i : in_i;
    end
    
    always_ff @(posedge updateDR) begin
        r2_reg <= r1_reg;
    end

    assign so_o  = r1_reg;
    assign out_o = mode_i ? r2_reg : in_i;

endmodule
