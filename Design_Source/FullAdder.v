`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/29 17:44:48
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
    input Cin,
    input a,
    input b,
    output Sum,
    output Carry
    );

    wire w_Sum1, w_Carry1, w_Carry2;

    // Instantiate two HalfAdders
    // First HalfAdder computes the sum of a and b
    HalfAdder u_HA1 (
        .a(a),
        .b(b),
        .Sum(w_Sum1),
        .Carry(w_Carry1)
    );
    // Second HalfAdder computes the sum of w_Sum1 and Cin
    HalfAdder u_HA2 (
        .a(w_Sum1),
        .b(Cin),
        .Sum(Sum),
        .Carry(w_Carry2)
    );

    // Final Carry is the OR of the two Carry outputs
    assign Carry = w_Carry1 | w_Carry2; 
    
endmodule
