`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/29 17:33:45
// Design Name: 
// Module Name: tb_HalfAdder
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


module tb_HalfAdder();

    reg a;
    reg b;
    wire Sum;
    wire Carry; 

    // Instantiate the HalfAdder module
    HalfAdder test_HA(
        .a(a),
        .b(b),
        .Sum(Sum),
        .Carry(Carry)
    );

    initial begin
        #00 a = 0; b = 0; // Test case 1: a=0, b=0
        #10 a = 0; b = 1; // Test case 2: a=0, b=1
        #10 a = 1; b = 0; // Test case 3: a=1, b=0
        #10 a = 1; b = 1; // Test case 4: a=1, b=1
        #10; $finish; // Wait for a while to observe the outputs
    end

endmodule
