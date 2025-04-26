/*
    File name: tap_pkg.sv
    Description:
    Author: Marko Gjorgjievski
    Date created: 19.04.2025
*/

package tap_pkg;

    //TODO: Check if necessary local params.
    // RAM Defininitions
    localparam int memdepth = 256; // Memory depth

    // Busses
    localparam int instruction_width = 4;
    localparam int ramAddress_width = 8;
    localparam int globalAddress_width = 64;
    localparam int data_width = 32;

       // Instructions
    localparam [instruction_width-1:0] EXTEST  = 4'b0000;
    localparam [instruction_width-1:0] SAMPLE  = 4'b0001;
    localparam [instruction_width-1:0] PRELOAD = 4'b0010;
    localparam [instruction_width-1:0] LOAD_PROGRAM = 4'b0011;
    localparam [instruction_width-1:0] BYPASS  = 4'b1111;

endpackage