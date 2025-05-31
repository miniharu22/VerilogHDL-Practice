`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 15:26:48
// Design Name: 
// Module Name: FullAdder
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


module FullAdder(

    input A,
    input B,
    input Cin,
    output S,
    output Cout
    );

    wire HA0_S, HA0_C;
    wire HA1_S, HA1_C;

    // Output sum from the first half adder
    assign S = HA1_S;   
    // Carry out is the OR of the carry outputs from both half adders
    assign Cout = HA0_C | HA1_C;    

    // First Half Adder
    HalfAdder HA0 (
        .A(A),
        .B(B),
        .S(HA0_S),
        .C(HA0_C)
    );
    // Second Half Adder
    HalfAdder HA1 (
        .A(HA0_S),
        .B(Cin),
        .S(HA1_S),
        .C(HA1_C)
    );

endmodule
