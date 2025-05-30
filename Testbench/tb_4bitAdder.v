`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 16:07:37
// Design Name: 
// Module Name: tb_4bitAdder
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

    reg A0, A1, A2, A3;
    reg B0, B1, B2, B3;
    wire S0, S1, S2, S3;
    wire Cout;

    // Instantiate the 4-bit adder
    _4bitAdder test_bench (
        .A0(A0),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .B0(B0),
        .B1(B1),
        .B2(B2),
        .B3(B3),
        .S0(S0),
        .S1(S1),
        .S2(S2),
        .S3(S3),
        .Cout(Cout)
    );

    initial begin
        #00 A3 = 0; A2 = 0; A1 = 1; A0 = 0; 
            B3 = 1; B2 = 1; B1 = 0; B0 = 1;
        #10 A3 = 1; A2 = 0; A1 = 1; A0 = 1;
            B3 = 1; B2 = 0; B1 = 0; B0 = 0;
        #10 A3 = 0; A2 = 1; A1 = 1; A0 = 1;
            B3 = 1; B2 = 1; B1 = 0; B0 = 1;
        #10 $finish; // End the simulation
    end

endmodule
