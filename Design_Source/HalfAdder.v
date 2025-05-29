`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/29 17:22:23
// Design Name: 
// Module Name: HalfAdder
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


module HalfAdder(
    // Port list
    input a,
    input b,
    output Sum,
    output Carry
    );

    // Design Circuit
    assign Sum = a ^ b;  // Sum is the XOR of inputs a and 
    assign Carry = a & b; // Carry is the AND of inputs a and b
endmodule
