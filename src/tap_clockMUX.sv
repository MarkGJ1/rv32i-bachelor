/*
    File name: tap_controller.sv
    Description: Selecting chip clock or test clock for internal logic.
                No testbench present nor in module used...
                TODO: Remove module if deemed unnecessary.
    Author: Marko Gjorgjievski
    Date created: 26.04.2025
*/

module tap_clockMUX(
    input logic clk_i,
    input logic tck_i,
    input logic clksel_i,
    output logic clk_o
    );
    
    always_comb begin 
        case (clksel_i)
            2'b1:       clk_o = clk_i; //sel_i = 00 not defined, so write to bypass if it occurs
            2'b0:       clk_o = tck_i;
            default:    clk_o = 0;
        endcase;
    end

endmodule
