`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/29 18:13:15
// Design Name: 
// Module Name: tb_4BitAdder
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


module tb_4bitAdder();
    reg a0;
    reg a1;
    reg a2;
    reg a3;
    reg b0;
    reg b1;
    reg b2;
    reg b3;
    wire Sum0;
    wire Sum1;
    wire Sum2;
    wire Sum3;
    wire Carry;
    
    _4BitAdder test_banch(
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .Sum0(Sum0),
        .Sum1(Sum1),
        .Sum2(Sum2),
        .Sum3(Sum3),
        .Carry(Carry)
    );
    
    initial begin
        #00 a3 = 0; a2 = 0; a1 = 1; a0 = 0; b3 = 1; b2 = 1; b1 = 0; b0 = 1;
        #10 a3 = 1; a2 = 0; a1 = 1; a0 = 1; b3 = 1; b2 = 0; b1 = 0; b0 = 0;
        #10 a3 = 0; a2 = 1; a1 = 1; a0 = 1; b3 = 1; b2 = 1; b1 = 0; b0 = 1;
        #10 $finish;
    end

endmodule

