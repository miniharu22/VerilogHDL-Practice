`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/31 21:52:52
// Design Name: 
// Module Name: transmitter
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


module transmitter(

    input clk,
    input reset,
    input start,
    input br_tick,
    input [7:0] data,
    output tx,
    output tx_done
    );

    localparam IDLE = 0, START = 1, STOP = 10;
    localparam D0 = 2, D1 = 3, D2 = 4, D3 = 5, D4 = 6, D5 = 7, D6 = 8, D7 = 9;

    reg [3:0] state, state_next;
    reg [7:0] r_data;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;

    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

    always @(posedge clk, posedge reset) // Synchronous reset
    begin
        if (reset) begin           // Reset condition
            state <= IDLE;         // Reset state to IDLE
            tx_reg <= 1'b0;        // Default tx line high (idle state)
            tx_done_reg <= 1'b0;   // Reset tx_done signal
        end else begin                      // Normal operation
            state <= state_next;            // Update state
            tx_reg <= tx_next;              // Update tx line
            tx_done_reg <= tx_done_next;    // Update tx_done signal
        end
    end

    always @(*) // Combinational logic for state transitions and tx line control
    begin
        state_next = state; // Default next state is current state

        case (state)    // State machine for transmitter
            IDLE : if (start) state_next = START;
            START : if (br_tick) state_next = D0;
            D0 : if (br_tick) state_next = D1;
            D1 : if (br_tick) state_next = D2;
            D2 : if (br_tick) state_next = D3;
            D3 : if (br_tick) state_next = D4;
            D4 : if (br_tick) state_next = D5;
            D5 : if (br_tick) state_next = D6;
            D6 : if (br_tick) state_next = D7;
            D7 : if (br_tick) state_next = STOP;
            STOP : if (br_tick) state_next = IDLE;
        endcase
    end        

    always @(*)  // Combinational logic for tx line and tx_done signal
    begin
        tx_next = tx_reg;   // Default next tx line value is current value
        tx_done_next = 1'b0;// Default tx_done signal is low

        case (state)
            IDLE : tx_next = 1'b1;  // Idle state, tx line high
            START : begin           // Start state, tx line low
                tx_next = 1'b0;     // Start bit is low
                r_data = data;      // Store data to be transmitted
            end
            D0 : tx_next = r_data[0]; 
            D1 : tx_next = r_data[1];
            D2 : tx_next = r_data[2];
            D3 : tx_next = r_data[3];
            D4 : tx_next = r_data[4];
            D5 : tx_next = r_data[5];
            D6 : tx_next = r_data[6];
            D7 : tx_next = r_data[7];
            STOP : begin        // Stop state, tx line high
                tx_next = 1'b1; // Stop bit is high
                if (state_next == IDLE) tx_done_next = 1'b1; 
                // Set tx_done signal high when returning to IDLE
            end 
        endcase
    end

endmodule
