`timescale 1ns / 1ps

module adder (
    input       clk,
    input       reset,
    input       valid,
    input [3:0] a,
    input [3:0] b,

    output [3:0] sum,
    output       carry
);

    reg [3:0] sum_reg, sum_next;
    reg carry_reg, carry_next;


    // output combinational logic
    assign sum   = sum_reg;
    assign carry = carry_reg;


    // state register
    always @(posedge clk, posedge reset) // synchronous reset
    begin  
        if (reset) begin        // reset state
            sum_reg   <= 0;     // reset sum register
            carry_reg <= 1'b0;  // reset carry register
        end else begin                  // next state
            sum_reg   <= sum_next;      // update sum register
            carry_reg <= carry_next;    // update carry register
        end
    end


    // next state combinational logic
    always @(*) begin          
        carry_next = carry_reg; // carry register holds the previous carry value
        sum_next   = sum_reg;   // sum register holds the previous sum value

        if (valid) begin        // if valid signal is high, perform addition
            {carry_next, sum_next} = a + b; // perform addition
        end
    end

endmodule