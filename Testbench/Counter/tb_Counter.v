`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 16:39:49
// Design Name: 
// Module Name: tb_Counter
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


module tb_Counter();

parameter clk_period = 10; // Define clock period

reg RST, CLK, DIR;  // Declare inputs
wire [2:0] LED;     // Declare output

Counter uut (
    .RST(RST),
    .CLK(CLK),
    .DIR(DIR),
    .LED(LED)
);

initial begin           // Initialize inputs
    RST = 1'b1;         // Set reset high -> 1 sig
    #(clk_period * 20); // Hold reset for 20 clock cycles (200ns)
    RST = 1'b0;         // Release reset  -> 0 sig
end // intial RST

initial CLK = 1'b0;     // Initialize CLK to 0

always #clk_period CLK = ~CLK; // Toggle CLK every clk_period

initial begin
    DIR = 1'b0;         // Initialize DIR to 0, Setting the Start Direction
    wait (RST == 1'b0); // Wait for reset to be released
    #(clk_period * 30); // Wait for 30 clock cycles (300ns)
    DIR = 1'b1;         // Change DIR to 1, Reverse direction
    #(clk_period * 30); // Wait for 30 clock cycles (300ns)
    DIR = 1'b0;         // Change DIR back to 0, Reverse direction again
end // initial DIR

endmodule
