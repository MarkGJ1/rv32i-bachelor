/*
    File name: sign_extension_unit.sv
    Description: Sign extension units derive the immediate values from
                an instruction's fields depending on which type of 
                instruction is used.
    Author: Marko Gjorgjievski
    Date created: 15.03.2025
    Date modified: 14.04.2025
*/

import pkg_config::*;

module sign_extension (
    input logic [INST_WIDTH - 1:0] inst_i,                // Original 32-bit instruction
    input logic [OPCODE - 1:0] opcode_i,                   // Opcode for instruction
    output logic [DATA_WIDTH - 1:0] immediate_extended_o   // Extended 32-bit immediate value    
);

    // Sign-extend the immediate value based on the opcode
    always @* begin
        unique case (opcode_i)

            OP_ALUI, OP_LOAD, OP_JALR:  // ALU Immediate, Load, and JALR
                immediate_extended_o = $signed(inst_i[31:20]); // Sign-extend for immediate

            OP_STORE:  // Store Instructions (SB, SH, SW)
                immediate_extended_o = $signed({inst_i[31:25], inst_i[11:7]});

            OP_LUI, OP_AUIPC:  // LUI (Load Upper Immediate), AUIPC (Add Upper Immediate to PC)
                immediate_extended_o = {inst_i[31:12], 12'h000}; // Upper 20 bits are used, lower 12 bits are zero

            OP_JAL:  // JAL (Jump and Link)
                immediate_extended_o = $signed({inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0}); // Jump address calculation

            OP_BRANCH:  // Branch Instructions (BEQ, BNE, BLT, etc.)
                immediate_extended_o = $signed({inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0}); // Branch target address calculation
                                                
            default:
                immediate_extended_o = 32'hFFFF_FFFF; // Default to all ones for invalid opcodes
        endcase
    end

endmodule