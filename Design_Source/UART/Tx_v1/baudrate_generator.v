`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 21:56:14
// Design Name: 
// Module Name: baudrate_generator
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


module baudrate_generator(
    
    input clk,
    input reset,

    output br_tick
    );

    // Baud rate: 1000000 bps
    // Clock frequency: 100 MHz
    reg [$clog2(100_000_000/100_000_00)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign br_tick = tick_reg;

    always @(posedge clk, posedge reset)   // Synchronous reset
    begin   
        if (reset) begin        // Reset condition
            counter_reg <= 0;   // Reset counter
            tick_reg <= 1'b0;   // Reset tick signal
        end else begin
            counter_reg <= counter_next;    // Update counter
            tick_reg <= tick_next;          // Update tick signal
        end
    end

    always @(*) // Combinational logic for counter and tick signal
    begin
        counter_next = counter_reg; // Default next value is current value
        if (counter_reg == 100_000_000 / 100_000_00 - 1) // Check if counter reached the limit
        begin
            counter_next = 0;   // Reset counter
            tick_next = 1'b1;   // Set tick signal high
        end else begin                      // If not reached limit
            counter_next = counter_reg + 1; // Increment counter
            tick_next = 1'b0;               // Set tick signal low
        end
    end
    
endmodule
