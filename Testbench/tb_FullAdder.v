`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 15:32:00
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

    reg A;
    reg B;
    reg Cin;
    wire S;
    wire Cout; 

    FullAdder test_FA(
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    initial begin
        #00 Cin = 0; A = 0; B = 0; // Test case 1: 0 + 0 + 0    
        #10 Cin = 0; A = 0; B = 1; // Test case 2: 0 + 1 + 0
        #10 Cin = 0; A = 1; B = 0; // Test case 3: 1 + 0 + 0
        #10 Cin = 0; A = 1; B = 1; // Test case 4: 1 + 1 + 0
        #10 Cin = 1; A = 0; B = 0; // Test case 5: 0 + 0 + 1
        #10 Cin = 1; A = 0; B = 1; // Test case 6: 0 + 1 + 1
        #10 Cin = 1; A = 1; B = 0; // Test case 7: 1 + 0 + 1
        #10 Cin = 1; A = 1; B = 1; // Test case 8: 1 + 1 + 1
        #10 $finish; // End simulation
    end

endmodule
