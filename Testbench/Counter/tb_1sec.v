`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 18:52:13
// Design Name: 
// Module Name: tb_1sec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_1sec();

    parameter CLK_PED = 10.0; // 100 MHz clock period

    reg reset, clk;
    wire dout;

    _1sec #( .clk_freq(10)) // Instantiate the _1sec module
        uut (
            .RST(reset),
            .CLK(clk),
            .LED(dout)
        );
    
    initial begin
        reset = 1'b1;       // Asset reset (0 to 1)
        #(CLK_PED + 10);    // Wait for a few clock cycles
        reset = 1'b0;       // Deassert reset (1 to 0)
    end

    initial clk = 1'b0;
    always #(CLK_PED / 2) clk = ~clk; 

endmodule
