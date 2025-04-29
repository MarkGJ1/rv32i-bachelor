/*
    File name: tap_controller.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 29.04.2025
*/

module tap_InstructionRegister (
    input logic tck_i,
    input logic trst_i,
    input logic shiftIR_i,
    input logic updateIR_i,
    input logic tdi_i,
    output logic tdo_o,
    output logic [instruction_width-1:0] instruction_o // 4-bit instruction register
);

    logic [instruction_width-1:0] ir_s;

    always_ff @(posedge tck_i or posedge trst_i) begin
        if (trst_i)
            ir_s <= '0;
        else if (shiftIR_i) begin
            ir_s <= {tdi_i, ir_s[3:1]}; // Shift in instruction
        end
    end

    assign tdo_o = ir_s[0]; // Output least significant bit during shifting

    always_ff @(posedge tck_i) begin
        if (updateIR_i) begin
            instruction_o <= ir_s; // Update instruction register
        end
    end

endmodule
