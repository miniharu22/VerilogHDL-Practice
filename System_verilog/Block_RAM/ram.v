`timescale 1ns / 1ps

module ram (
    input       clk,
    input [9:0] address,
    input [7:0] wdata,
    input       wr_en,

    output [7:0] rdata
);

    reg [7:0] mem[0:2**10-1];  // n space with 8bit memory   

    integer i;

    initial begin   // Initialize memory to zero
        for (i = 0; i < 2 ** 10 - 1; i = i + 1) begin
            mem[i] = 0;
        end
    end

    always @(posedge clk) begin // Write data on the positive edge of the clock
        if (!wr_en) begin       // If write enable is low, do nothing
            mem[address] <= wdata;  // Write data to memory at the specified address
        end
    end

    // Read data from memory at the specified address
    assign rdata = mem[address];    

endmodule