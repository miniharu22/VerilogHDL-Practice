`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 16:31:35
// Design Name: 
// Module Name: Counter
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


module Counter(
    input RST,
    input CLK,
    input DIR,
    output [31:0] LED
    );

    reg [31:0] cnt; // Store cnt with 32-bit counter

    assign LED = cnt[31:0]; // Assign the upper 32 bits of cnt to LED

always @(posedge CLK)       // Trigger on the rising edge of CLK
begin
    if (RST == 1'b1)        // Check if RST is high
        cnt <= 32'd0;       // Reset cnt to 0
    else begin
        if (DIR == 1'b1)    // Check if DIR is high
            cnt <= cnt + 1; // Increment cnt
        else                // Check if DIR is low
            cnt <= cnt - 1; // Decrement cnt
    end
end // always

endmodule
