`timescale 1ns / 1ps

// Control Unit module for managing states and control signals
module ControlUnit (
    input clk,
    input reset,        
    input ALt10,            // Comparator output : 1 if A < 10

    output reg ASrcMuxSel,  // Mux select signal 
    output reg ALoad,       // Load enable signal for A register
    output reg OutBufSel    // Output buffer enable signal   
);

    localparam S0 = 3'd0,   // state 0 : Initialization
               S1 = 3'd1,   // state 1 : Check if A < 10
               S2 = 3'd2,   // state 2 : Output A
               S3 = 3'd3,   // state 3 : Increment A 
               S4 = 3'd4;   // state 4 : HALT (stop state)

    reg [2:0] state, state_next; // State register


    always @(posedge clk, posedge reset) begin
        if (reset) state <= S0;
        else state <= state_next;
    end

    always @(*) begin
        state_next = state; // Default stay in current state

        case (state)
            S0: state_next = S1;    // Initialization done -> move to S1
            // S1: begin               
            //     if (ALt10) 
            //         state_next = S2;    // If A < 10, move to output state
            //     else 
            //         state_next = S4;    // Else, go to HATT State
            // end
            S1: begin
                if (ALt10) state_next = S2;
                else state_next = S0;
            end
            S2: state_next = S3;        // Output state -> Increment state
            S3: state_next = S1;        // After Increment -> check A < 10 again
            S4: state_next = S4;        // HALT state : remain
            default: state_next = S1;   // Default Fallback
        endcase
    end

    // Output Logic
    always @(*) begin
        // Default values : deassert all control signals
        ASrcMuxSel = 1'b0;
        ALoad = 1'b0;
        OutBufSel = 1'b0;

        case (state)
            S0: begin
                ASrcMuxSel = 1'b0;  // selcct 0 input for Mux
                ALoad = 1'b1;       // load 0 into A register
                OutBufSel = 1'b0;   // output buffer disabled
            end
            S1: begin               
                ASrcMuxSel = 1'b1;  // select adder output (A+1) for Mux
                ALoad = 1'b0;       // hold A regiseter value
                OutBufSel = 1'b0;   // output buffer disabled
            end
            S2: begin   
                ASrcMuxSel = 1'b1;  // selcet adder output (A+1)
                ALoad = 1'b0;       // hold A regiseter value
                OutBufSel = 1'b1;   // enable output buffer
            end
            S3: begin
                ASrcMuxSel = 1'b1;  // select adder output (A+1)
                ALoad = 1'b1;       // load incremented value into A register
                OutBufSel = 1'b0;   // output buffer disabled
            end
            S4: begin
                ASrcMuxSel = 1'b1;  // select add output (A+1)
                ALoad = 1'b0;       // Hold A register
                OutBufSel = 1'b0;   // output buffer disabled
            end
            default: begin
                ASrcMuxSel = 1'b0; 
                ALoad = 1'b0;
                OutBufSel = 1'b0;
            end
        endcase
    end
endmodule