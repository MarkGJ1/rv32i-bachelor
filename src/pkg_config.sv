/*
    File name: pkg_config.sv
    Description: Package used for constant values.
    Author: Marko Gjorgjievski
    Date: 13.01.2025
*/

package pkg_config;

    // Used in reg_file.sv
    localparam int DATA_WIDTH = 32;
    localparam int NUM_REGISTER = 32;

    //Used in instr_mem.sv
    localparam int INST_WIDTH = 32;

endpackage