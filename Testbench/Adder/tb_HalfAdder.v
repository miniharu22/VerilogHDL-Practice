`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 15:16:56
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

    reg A;
    reg B;
    wire S;
    wire C;

    HalfAdder test_HA(
        .A(A),
        .B(B),
        .S(S),
        .C(C)
    );

    initial begin
        #00 A = 0; B = 0; // Test case 1: A=0, B=0
        #10 A = 0; B = 1; // Test case 2: A=0, B=1
        #10 A = 1; B = 0; // Test case 3: A=1, B=0
        #10 A = 1; B = 1; // Test case 4: A=1, B=1
        #10 $finish; // End simulation
    end

endmodule
