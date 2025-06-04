`timescale 1ns / 1ps

module RV32I (
    input logic clk,
    input logic reset
);

    logic [31:0] w_InstrMemAddr, w_InstrMemData;

    CPU_Core U_CPU_Core (
        .clk(clk),
        .reset(reset),
        .machineCode(w_InstrMemData),

        .instrMemRAddr(w_InstrMemAddr)
    );

    InstructionMemory U_ROM ( 
        .addr(w_InstrMemAddr),

        .data(w_InstrMemData)
    );

endmodule