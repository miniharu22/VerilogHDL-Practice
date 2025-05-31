`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 18:44:52
// Design Name: 
// Module Name: _1sec
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


module _1sec(

    input RST,
    input CLK,
    output reg LED
    );

    parameter clk_freq = 125_000_000; // 125 MHz

    reg enable;
    reg [31:0] cnt;

    always @(posedge CLK)   // Clock domain
    begin
        if(RST) begin       // Reset condition
            cnt <= 32'd0;   // Reset counter
            enable <= 1'b0; // Disable output
        end else begin      // Normal operation
            if(cnt == clk_freq -1 ) begin   // Check if counter reached 1 second
                cnt <= 32'd0;   // Reset counter
                enable <= 1'b1; // Enable output
            end else begin      
                cnt <= cnt + 1; // Increment counter
                enable <= 1'b0; // Keep output disabled
            end
        end
    end

    always @(posedge CLK)       // Output domain
    begin       
        if(RST)             // Reset condition
            LED <= 1'b0;    // Reset LED
        else if (enable)    // If enabled
            LED <= ~LED;    // Toggle LED
    end

endmodule
