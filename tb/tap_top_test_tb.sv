`timescale 1ns / 1ps

import pb_pack::*;

module pb_tb_toplevel;

    // Clock and control signals
    logic tck_s, tms_s, tdi_s, trst_s, tdo_s;
    logic clk_s, rst_s;
    logic [globalAddress_width-1:0] pc_s, address_s;
    logic [data_width-1:0] instr_s; 
    
    // DUT: Top-Level Module
    pb_topLevel dut (
        .trst_i(trst_s),
        .tdi_i(tdi_s),
        .tms_i(tms_s),
        .tck_i(tck_s),
        .tdo_o(tdo_s),
        .clk_i(clk_s),
        .readAddr_i(pc_s),
        .readData_o(instr_s)
    );
  

    // Program data
    logic [data_width-1:0] instructions_s [0:55];
    initial begin
        instructions_s[0]  = 32'h00500113; // ADDI x2, x0, 5
        instructions_s[1]  = 32'h00C00193; // ADDI x3, x0, 12
        instructions_s[2]  = 32'h00800213; // ADDI x4, x0, 8
        instructions_s[3]  = 32'h003102B3; // ADD x5, x2, x3
        instructions_s[4]  = 32'h00523423; // SW x5, 8(x4)
        instructions_s[5]  = 32'h01003303; // LW x6, 16(x0)
        instructions_s[6]  = 32'h00030513; // ADDI x10, x6, 0
        instructions_s[7]  = 32'h0C4000EF; // JAL x1, 0xC40
        instructions_s[8]  = 32'h402182B3; // SUB x5, x3, x2
        instructions_s[9]  = 32'h00028513; // ADDI x10, x5, 0
        instructions_s[10] = 32'h0B8000EF; // JAL x1, 0xB80
        instructions_s[11] = 32'h00000513; // ADDI x10, x0, 0
        instructions_s[12] = 32'h50000293; // ADDI x5, x0, 1280
        instructions_s[13] = 32'h00523823; // SW x5, 8(x4)
        instructions_s[14] = 32'h01900303; // LW x6, 24(x0)
        instructions_s[15] = 32'h00030513; // ADDI x10, x6, 0
        instructions_s[16] = 32'h0A0000EF; // JAL x1, 0xA00
        instructions_s[17] = 32'h00000513; // ADDI x10, x0, 0
        instructions_s[18] = 32'h08500293; // ADDI x5, x0, 133
        instructions_s[19] = 32'h00829293; // ADDI x5, x5, 8
        instructions_s[20] = 32'h00523823; // SW x5, 8(x4)
        instructions_s[21] = 32'h01900303; // LW x6, 24(x0)
        instructions_s[22] = 32'h00030513; // ADDI x10, x6, 0
        instructions_s[23] = 32'h084000EF; // JAL x1, 0x840
        instructions_s[24] = 32'h00000513; // ADDI x10, x0, 0
        instructions_s[25] = 32'h0FF00293; // ADDI x5, x0, 255
        instructions_s[26] = 32'h01029293; // ADDI x5, x5, 16
        instructions_s[27] = 32'h00523823; // SW x5, 8(x4)
        instructions_s[28] = 32'h01A01303; // LW x6, 40(x0)
        instructions_s[29] = 32'h00030513; // ADDI x10, x6, 0
        instructions_s[30] = 32'h068000EF; // JAL x1, 0x680
        instructions_s[31] = 32'h00000513; // ADDI x10, x0, 0
        instructions_s[32] = 32'h0FE00293; // ADDI x5, x0, 254
        instructions_s[33] = 32'h01029293; // ADDI x5, x5, 16
        instructions_s[34] = 32'h01029293; // ADDI x5, x5, 16
        instructions_s[35] = 32'h00523823; // SW x5, 8(x4)
        instructions_s[36] = 32'h01C02303; // LW x6, 56(x0)
        instructions_s[37] = 32'h00030513; // ADDI x10, x6, 0
        instructions_s[38] = 32'h048000EF; // JAL x1, 0x480
        instructions_s[39] = 32'h00000513; // ADDI x10, x0, 0
        instructions_s[40] = 32'h0FD00293; // ADDI x5, x0, 253
        instructions_s[41] = 32'h00523823; // SW x5, 8(x4)
        instructions_s[42] = 32'h01802303; // LW x6, 24(x0)
        instructions_s[43] = 32'h00030513; // ADDI x10, x6, 0
        instructions_s[44] = 32'h030000EF; // JAL x1, 0x300
        instructions_s[45] = 32'h00C00113; // ADDI x2, x0, 12
        instructions_s[46] = 32'h00A00193; // ADDI x3, x0, 10
        instructions_s[47] = 32'h003162B3; // ADD x5, x2, x3
        instructions_s[48] = 32'h00028513; // ADDI x10, x5, 0
        instructions_s[49] = 32'h01C000EF; // JAL x1, 0x1C0
        instructions_s[50] = 32'h00C00113; // ADDI x2, x0, 12
        instructions_s[51] = 32'h00A00193; // ADDI x3, x0, 10
        instructions_s[52] = 32'h003172B3; // ADD x5, x2, x3
        instructions_s[53] = 32'h00028513; // ADDI x10, x5, 0
        instructions_s[54] = 32'h008000EF; // JAL x1, 0x80
        instructions_s[55] = 32'h00C0006F; // JAL x0, 0xC0
    end

    // Clock generation
    initial begin
        tck_s = 0;
        forever #5 tck_s = ~tck_s; // 10ns clock period
    end
    
    initial begin
        clk_s = 0;
        forever #7 clk_s = ~clk_s; // 10ns clock period
    end
    
    // Test logic
    initial begin
        // Initialize inputs
        tms_s = 0;
        tdi_s = 0;
        trst_s = 0;
        rst_s = 0;
        @(posedge tck_s);       
        //pc_s = 0;
        // TEST 1: Reset and Transition to RUN_TEST_IDLE
        $display("TEST 1: Reset and Transition to RUN_TEST_IDLE...");
        trst_s = 1; // Assert reset
        tms_s = 1;
        @(posedge tck_s);
        trst_s = 0; // Deassert reset
        tms_s = 0;
        @(posedge tck_s);
        $display("TAP is in RUN_TEST_IDLE.");
        
        $display("TEST 2: Load LOAD_PROGRAM");
        // Set IR to LOAD_PROGRAM
        tms_s = 1; // SELECT_DR_SCAN
        @(posedge tck_s);
        tms_s = 1; // SELECT_IR_SCAN
        @(posedge tck_s);
        tms_s = 0; // SHIFT_IR
        @(posedge tck_s);
        for (int i = 0; i < 4; i++) begin
            @(posedge tck_s);
            if(i==2) begin tdi_s = LOAD_PROGRAM[i]; tms_s = 1; end //EXIT1_IR
            else tdi_s = LOAD_PROGRAM[i]; // Shift in BYPASS instruction
        end
        tms_s = 1; // UPDATE_IR
        @(posedge tck_s);
        tms_s = 0; // IDLE
        @(posedge tck_s);
        $display("TEST 3: Check if Instruction Register TDO Works (Should return LOAD_PROGRAM (0011)");
        // Set IR to LOAD_PROGRAM
        tms_s = 1; // SELECT_DR_SCAN
        @(posedge tck_s);
        tms_s = 1; // SELECT_IR_SCAN
        @(posedge tck_s);
        tms_s = 0; // SHIFT_IR
        @(posedge tck_s);
        for (int i = 0; i < 4; i++) begin
            @(posedge tck_s);           
            if(i==2) begin tdi_s = BYPASS[i]; tms_s = 1; end //EXIT1_IR
            else tdi_s = BYPASS[i]; // Shift in BYPASS instruction
            assert(tdo_s == LOAD_PROGRAM[i])
                $display("Bit Correct, TDO is %d",tdo_s);
                else  
                $fatal("Test failed.");

        end
        tms_s = 1; // UPDATE_IR
        @(posedge tck_s);
        tms_s = 0; // IDLE
        @(posedge tck_s);
        
        $display("TEST 4: TEST if BYPASS works");
        // BYPASS was loaded before to thes IR TDO. So move to SHIFT_DR and check...
        tms_s = 1; // SELECT DR SCAN
        @(posedge tck_s);
        tms_s = 0; // SHIFT_DR SCAN
        @(posedge tck_s);        
        
        for (int i = 0; i < 32; i++) begin
            tdi_s = instructions_s[0][i]; // Apply test bit to tdi_s
            @(posedge tck_s); // Wait for clock edge
            assert(tdo_s == instructions_s[0][i]) 
                    $display("Bit %d Correct (%b)", i,instructions_s[0][i]);
            else 
                    $fatal("Bypass Test failed.");
        end
        tms_s = 1; // EXIT1
        @(posedge tck_s);
        tms_s = 1; // UPDATE DR
        @(posedge tck_s);
        tms_s = 0; // IDLE
        @(posedge tck_s);
        $display("BYPASS TEST Successful");
        $display("TEST 5: TEST IF Data Register TDO works");

        // Set IR to LOAD_PROGRAM
        tms_s = 1; // SELECT_DR_SCAN
        @(posedge tck_s);
        tms_s = 1; // SELECT_IR_SCAN
        @(posedge tck_s);
        tms_s = 0; // SHIFT_IR
        @(posedge tck_s);
        for (int i = 0; i < 4; i++) begin
            @(posedge tck_s);
            if(i==2) begin tdi_s = LOAD_PROGRAM[i]; tms_s = 1; end //EXIT1_IR
            else tdi_s = LOAD_PROGRAM[i]; // Shift in BYPASS instruction
        end
        tms_s = 1; // UPDATE_IR
        @(posedge tck_s);
        tms_s = 0; // IDLE
        @(posedge tck_s);
       
        // TEST LOAD Program
        // Transition through DR path
        address_s = 0;
        for (int j = 0; j<56; j++) begin
            tms_s = 1; // SELECT_DR_SCAN
            @(posedge tck_s);
            tms_s = 0; // SHIFT_DR
            @(posedge tck_s);

            // Shift in address_s and data
            for (int i = 0; i < 96; i++) begin
                @(posedge tck_s);        
                if (i < 64) tdi_s = address_s[i];        // First 64 bits for address_s
                else if (i==94) begin tdi_s = instructions_s[j][i - 64]; tms_s=1; end //EXIT1_DR
                else        tdi_s = instructions_s[j][i - 64];  // Next 32 bits for data
            end
       
            tms_s = 1; // UPDATE_DR
            @(posedge tck_s);
            tms_s = 0; //IDLE
            address_s = address_s +1;
            end

            $display("TEST 4: Check RAM Content...");
            @(posedge clk_s);
            pc_s = 0;          
            for(int i = 0; i<56; i++)begin
                @(posedge clk_s);            
                assert(instr_s == instructions_s[pc_s])
                $display("Instruction at address_s %d is correct. Got Instruction %h", pc_s, instr_s); 
                else 
                $error("Instruction at address_s %h is wrong. Got %h instead of %h",pc_s, instr_s, instructions_s[pc_s]);
                pc_s = pc_s +1;
            end
    
      
      $finish;
  
    end

endmodule
