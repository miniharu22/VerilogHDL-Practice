`ifndef __INTERFACE_SV_     // if not defined "__INTERFACE_SV_"
`define __INTERFACE_SV_     // then define it

`timescale 1ns / 1ps

interface fifo_interface;   // FIFO interface definition
    logic clk;              
    logic reset;

    logic wr_en;        // Write enable signal
    logic full;         // FIFO full signal
    logic [7:0] wdata;  // Write data signal
    
    logic rd_en;        // Read enable signal
    logic empty;        // FIFO empty signal
    logic [7:0] rdata;  // Read data signal
endinterface

`endif
