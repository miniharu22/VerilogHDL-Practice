`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 20:26:18
// Design Name: 
// Module Name: tb_FSM
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


module tb_FSM();

    parameter CLK_PERIOD = 10; // Clock period in ns

    reg RST, CLK;
    reg [1:0] SWT;
    wire [1:0] LED;

    FSM uut(
        .RST(RST),
        .CLK(CLK),
        .SWT(SWT),
        .LED(LED)
    );

    initial CLK = 1'b0;

    always #(CLK_PERIOD / 2) CLK = ~CLK; // Generate clock signal

    initial begin
        CLK = 1'b0;
        RST = 1'b0;
        SWT = 2'b00;

        #(CLK_PERIOD*10);   SWT = 2'b00; // Initial state, no switch pressed
        #(CLK_PERIOD*10);   SWT = 2'b01; // Press switch to go to state A
        #(CLK_PERIOD*10);   SWT = 2'b10; // Press switch to go to state B
        #(CLK_PERIOD*10);   SWT = 2'b11; // Press switch to go to state C
    end

endmodule
