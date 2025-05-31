`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 21:53:54
// Design Name: 
// Module Name: uart
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


module uart(

    input clk,
    input reset,
    input start,
    input [7:0] tx_data,

    output txd,
    output tx_done
    );

    wire w_br_tick;

    baudrate_generator U_BR_Gen(
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick)
    );

    transmitter U_TxD(
        .clk(clk),
        .reset(reset),
        .start(start),
        .br_tick(w_br_tick),
        .data(tx_data),
        .tx(txd),
        .tx_done(tx_done)
    );

endmodule
