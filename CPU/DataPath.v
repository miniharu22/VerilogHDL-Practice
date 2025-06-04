`timescale 1ns / 1ps

// DataPath Module
module DataPath(
    input clk,          
    input reset,
    input ASrcMuxSel,   // Multiplexer select signal for A register input
    input ALoad,        // Load enable signal for A register
    input OutBufSel,    // Output buffer enable signal

    output ALt10,       // Comparator output (A < 10)
    output [7:0] out    // Output data
    );

    // Internal wires
    // w_AdderResult: Output of the adder
    // w_MuxOut: Output of the 2-to-1 multiplexer
    // w_ARegOut: Output of the A register
    wire [7:0] w_AdderResult, w_MuxOut, w_ARegOut;

    // 2-to-1 Multiplexer
    mux_2x1 U_MUX(
            .sel(ASrcMuxSel),   // Select signal: 0 for 0, 1 for adder result
            .a(8'b0),           // Input a: constant zero
            .b(w_AdderResult),  // Input b: result of adder (A + 1)
        
            .y(w_MuxOut)        // Output: multiplexer output
        );

    // A Register
    register U_A_Reg(   
        .clk(clk),
        .reset(reset),
        .load(ALoad),   // Load enable signal
        .d(w_MuxOut),   // Data input from multiplexer
        .q(w_ARegOut)   // Output of the A register
    );

    // Comparator: checks if A < 10
    comparator U_Comp(
        .a(w_ARegOut),  // Input a: output of A register
        .b(8'd10),      // Input b: constant value 10

        .lt(ALt10)      // Output: less than signal (A < 10)
    );

    // Adder: adds 1 to the output of A register
    adder U_Adder(
        .a(w_ARegOut),  // Input a: output of A register
        .b(8'b1),       // Input b: constant value 1
        
        .y(w_AdderResult)   // Output: result of the addition (A + 1)
    );

    // Output Buffer: outputs the value of A register when enabled
    // outBuff U_OutBuf(
    //     .en(OutBufSel), // Enable signal for output buffer
    //     .a(w_ARegOut),  // Input: output of A register

    //     .y(out)         // Output: final output of the data path
    // );

    register U_Out_Reg(
        .clk(clk),
        .reset(reset),
        .load(OutBufSel),
        .d(w_ARegOut),
        .q(out)
    );

endmodule

// 2-to-1 Multiplexer Module
module mux_2x1 (
        input [7:0] a,     
        input [7:0] b,     
        input sel,         
        
        output reg [7:0] y  
    );

    // 2-to-1 Multiplexer: selects between two 8-bit inputs based on sel
    always @(*) begin       
        case(sel)           // sel signal determines which input to select
            1'b0 : y = a;   // If sel is 0, output is a
            1'b1 : y = b;   // If sel is 1, output is b
        endcase
    end
endmodule

// Register Module
module register (
    input clk,
    input reset,
    input load,
    input [7:0] d,
    output [7:0] q
);

    // Register: stores an 8-bit value with load and reset functionality
    reg [7:0] d_reg, d_next;
    assign q = d_reg;

// Sequential logic: updates d_reg on clock edge or reset
    always @(posedge clk , posedge reset) begin
        if (reset) d_reg <= 0;  // Reset the register to 0
        else d_reg <= d_next;   // Update register with next value
end

always @(*) begin
    if (load) d_next = d;   // If load is high, next value is d
    else d_next = d_reg;    // If load is low, next value remains the same
end
endmodule


// Comparator module: outputs 1 if a < b
module comparator (
    input [7:0] a,
    input [7:0] b,

    output lt           // Output: 1 if a < b, else 0
);
    assign lt = a < b;  // Compare a and b, output 1 if a is less than b
endmodule


// Adder module: outputs a + b
module adder (
    input [7:0] a,
    input [7:0] b,
    
    output [7:0] y
);
    assign y = a + b;   // Perform addition of a and b, output the result

endmodule

// Output Buffer module: outputs a when enabled, otherwise high impedance
module outBuff(
    input en,
    input [7:0] a,

    output [7:0] y
);

    // If en=1, output a; else output high-impedance
    assign y = en ? a : 8'bz; 
endmodule