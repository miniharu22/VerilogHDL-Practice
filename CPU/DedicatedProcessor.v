`timescale 1ns / 1ps

// Integrates Contol Unit and Data Path Modules
module DedicatedProcessor (
    input clk,
    input reset,

    output [7:0] out
);

    // Internal control and status signals
    wire w_ASrcMuxSel;  // Control: mux select for A register input
    wire w_ALoad;       // Control: load enable for A register
    wire w_OutBufSel;   // Control: output buffer enable
    wire w_ALt10;       // Status: A < 10 comparison result

    ControlUnit U_CU (
        .clk  (clk),
        .reset(reset),
        .ALt10(w_ALt10),

        .ASrcMuxSel(w_ASrcMuxSel),
        .ALoad(w_ALoad),
        .OutBufSel(w_OutBufSel)
    );


    DataPath U_DP (
        .clk(clk),
        .reset(reset),
        .ASrcMuxSel(w_ASrcMuxSel),
        .ALoad(w_ALoad),
        .OutBufSel(w_OutBufSel),

        .ALt10(w_ALt10),
        .out  (out)
    );

endmodule