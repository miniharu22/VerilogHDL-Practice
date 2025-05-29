`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/29 18:04:00
// Design Name: 
// Module Name: _4BitAdder
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


module _4BitAdder(

    input a0,
    input a1,
    input a2,
    input a3,
    input b0,
    input b1,
    input b2,
    input b3,
    output Sum0,
    output Sum1,
    output Sum2,
    output Sum3,
    output Carry
    );

    wire w_Carry0, w_Carry1, w_Carry2;

    HalfAdder u_HA1(
        .a(a0),
        .b(b0),
        .Sum(Sum0),
        .Carry(w_Carry0)
    );

    FullAdder u_FA1(
        .a(a1),
        .b(b1),
        .Cin(w_Carry0),
        .Sum(Sum1),
        .Carry(w_Carry1)
    );

    FullAdder u_FA2(
        .a(a2),
        .b(b2),
        .Cin(w_Carry1),
        .Sum(Sum2),
        .Carry(w_Carry2)
    );

    FullAdder u_FA3(
        .a(a3),
        .b(b3),
        .Cin(w_Carry2),
        .Sum(Sum3),
        .Carry(Carry)
    );
endmodule

