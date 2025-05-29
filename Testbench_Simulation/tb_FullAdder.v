`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/29 17:49:08
// Design Name: 
// Module Name: tb_FullAdder
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


module tb_FullAdder();

    reg a;
    reg b;
    reg Cin;
    wire Sum;
    wire Carry;

    // Instantiate the FullAdder module
    FullAdder test_FA(
        .a(a),
        .b(b),
        .Cin(Cin),
        .Sum(Sum),
        .Carry(Carry)
    );

    initial begin
        #00 Cin = 0; a = 0; b = 0; // Initial state
        #10 Cin = 0; a = 0; b = 1; // Test case 1
        #10 Cin = 0; a = 1; b = 0; // Test case 2
        #10 Cin = 0; a = 1; b = 1; // Test case 3
        #10 Cin = 1; a = 0; b = 0; // Test case 4
        #10 Cin = 1; a = 0; b = 1; // Test case 5
        #10 Cin = 1; a = 1; b = 0; // Test case 6
        #10 Cin = 1; a = 1; b = 1; // Test case 7
        #10 $finish; // End simulation
    end

endmodule
