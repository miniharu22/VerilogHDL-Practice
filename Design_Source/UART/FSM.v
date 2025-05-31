`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 20:11:12
// Design Name: 
// Module Name: FSM
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


module FSM(

    input RST,
    input CLK,
    input [1:0] SWT,
    output reg [1:0] LED,
    output VCC
    );

    assign VCC = 1'b1;  // Power supply signal

    // State definitions
    localparam [1:0] idle = 2'b00,      // Idle state
                     state_a = 2'b01,   // State A
                     state_b = 2'b10,   // State B
                     state_c = 2'b11;   // State C

    reg [1:0] curr_state, next_state;   // Current and next state registers

    always @ (posedge CLK)              // State transition logic
    begin
        if(RST)                         // Reset condition
            curr_state <= idle;         // Reset to idle state
        else                            // Transition to next state
            curr_state <= next_state;   // Update current state
    end

    always @ (curr_state, SWT)
    begin
        case (curr_state)
            idle : begin
                if (SWT == 2'b01)
                    next_state = state_a; // Transition to state A
                else
                    next_state = idle;    // Stay in idle state
                LED = 2'b00; // LED off
                end
        state_a : begin
                if (SWT == 2'b10)
                    next_state = state_b; // Transition to state B
                else
                    next_state = state_a; // Stay in state A
                LED = 2'b01; // LED on for state A
            end
        state_b : begin
                if (SWT == 2'b11)
                    next_state = state_c; // Transition to state C
                else
                    next_state = state_b; // Stay in state B
                LED = 2'b10; // LED on for state B
            end
        state_c : begin
                if (SWT == 2'b00)
                    next_state = idle; // Transition back to idle state
                else
                    next_state = state_c; // Stay in state C
                LED = 2'b11; // LED on for state C
            end
            default : next_state = idle; // Default case to handle unexpected states
        endcase
    end
endmodule
