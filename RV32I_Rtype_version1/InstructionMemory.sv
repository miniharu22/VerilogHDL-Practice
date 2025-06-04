`timescale 1ns / 1ps

// Storing Machine Code
module InstructionMemory (  
    input logic [31:0] addr,

    output logic [31:0] data
);

    logic [31:0] rom[0:63];

    initial begin
        rom[0] = 31'h005201b3;  // Add x6 x4 x5
        rom[1] = 31'h401184b3;  // Sub x7 x2 x1 => 1
        rom[2] = 31'h0020f433;  // And x8 x1 x2 => 0
    end

    assign data = rom[addr[31:2]];
endmodule