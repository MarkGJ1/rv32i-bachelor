/*
    File name: branch_unit.sv
    Description: The branch unit alters the instruction execution order
                depending on the given comparison selected for the branch.
    Author: Marko Gjorgjievski
    Date created: 15.03.2025
    Date modified: 12.04.2025
*/

import pkg_config::*;

module branch_unit (
    input wire branch_i,
    input wire [2:0] branch_op_i,
    input wire [DATA_WIDTH - 1:0] a_i,
    input wire [DATA_WIDTH - 1:0] b_i,
    output logic take_o
);

    always @* begin
        take_o = 0;
        if (branch_i) begin
            unique case (branch_op_i)
                BRANCH_BEQ:    take_o = (a_i == b_i);
                BRANCH_BNE:    take_o = (a_i != b_i);
                BRANCH_BLT:    take_o = ($signed(a_i) < $signed(b_i));
                BRANCH_BGE:    take_o = ($signed(a_i) >= $signed(b_i));
                BRANCH_BLTU:   take_o = (a_i < b_i);
                BRANCH_BGEU:   take_o = (a_i >= b_i);
                BRANCH_JAL_JALR: take_o = 1;
                default:        take_o = 0;
            endcase
        end
    end

endmodule
