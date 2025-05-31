`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 15:53:27
// Design Name: 
// Module Name: _4bitAdder
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


module _4bitAdder(

    input A0,
    input A1,
    input A2,
    input A3,
    input B0,
    input B1,
    input B2,
    input B3,
    output S0,
    output S1,
    output S2,
    output S3,
    output Cout
    );

    wire C0, C1, C2;

    HalfAdder HA0 (
        .A(A0),
        .B(B0),
        .S(S0),
        .C(C0)
    );
    FullAdder FA1 (
        .A(A1),
        .B(B1),
        .Cin(C0),
        .S(S1),
        .Cout(C1)
    );
    FullAdder FA2 (
        .A(A2),
        .B(B2),
        .Cin(C1),
        .S(S2),
        .Cout(C2)
    );
    FullAdder FA3 (
        .A(A3),
        .B(B3),
        .Cin(C2),
        .S(S3),
        .Cout(Cout)
    );

endmodule
