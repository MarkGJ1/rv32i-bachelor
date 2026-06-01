/*
    File name: tap_pkg.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

package tap_pkg;

    // Busses
    localparam int INSTRUCTION_WIDTH = 4;

    // Instructions
    localparam [INSTRUCTION_WIDTH-1:0] EXTEST  = 4'b0000;
    localparam [INSTRUCTION_WIDTH-1:0] SAMPLE  = 4'b0001;
    localparam [INSTRUCTION_WIDTH-1:0] PRELOAD = 4'b0010;
    localparam [INSTRUCTION_WIDTH-1:0] BYPASS  = 4'b1111;

endpackage