`timescale 1ns / 1ps

module MyUART (
    input       clk,
    input       reset,
    input       tx_start,
    input [7:0] tx_data,
    input       rx,

    output       tx,
    output       tx_done,
    output [7:0] rx_data,
    output       rx_done
);

    wire w_br_tick;
    wire w_tx;


    baudrate_generator #(
        .HERZ(9600)
    ) U_BR_Gen (
        .clk  (clk),
        .reset(reset),

        .br_tick(w_br_tick)
    );


    transmitter U_TxD (
        .clk(clk),
        .reset(reset),
        .start(tx_start),
        .br_tick(w_br_tick),
        .tx_data(tx_data),

        .tx(tx),
        .tx_done(tx_done)
    );


    receiver U_RxD (
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick),
        .rx(rx),

        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule


module baudrate_generator #(
    parameter HERZ = 9600
) (
    input clk,
    input reset,

    output br_tick
);

    // $clog2(100_000_000 / HERZ / 16) = 3
    reg [$clog2(100_000_000/HERZ/16)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;
    
    assign br_tick = tick_reg; // baudrate tick for baudrate with 16x oversampling

    always @(posedge clk, posedge reset) begin  // synchronous reset
        if (reset) begin            // reset the counter and tick
            counter_reg <= 0;       // reset counter
            tick_reg <= 1'b0;       // reset tick
        end else begin                      // on clock edge
            counter_reg <= counter_next;    // update counter
            tick_reg <= tick_next;          // update tick
        end
    end

    always @(*) begin                   // combinational logic for next state
        counter_next = counter_reg;     // default next counter value
        if (counter_reg == 3) begin     // if counter reaches 3 (for 16x oversampling)
            counter_next = 0;           // reset counter
            tick_next = 1'b1;           // set tick to 1
        end else begin                          // if counter is not at 3   
            counter_next = counter_reg + 1;     // increment counter
            tick_next = 1'b0;                   // set tick to 0   
        end
    end
endmodule


module transmitter (
    input clk,
    input reset,
    input br_tick,
    input start,
    input [7:0] tx_data,

    output tx,
    output tx_done
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3; // states for the FSM

    reg [1:0] state, state_next;            // state register and next state
    reg tx_done_reg, tx_done_next;          // register for transmission done signal
    reg tx_reg, tx_next;                    // register for the tx signal 
    reg [7:0] data_tmp_reg, data_tmp_next;  // temporary register for data to be transmitted
    reg [3:0]
        br_cnt_reg, br_cnt_next;            // register for baudrate counter with 16x oversampling
    reg [2:0]
        data_bit_cnt_reg,                   // register for counting data bits transmitted
        data_bit_cnt_next;                  // next value for data bit count    


    assign tx = tx_reg;
    assign tx_done = tx_done_reg;


    always @(posedge clk, posedge reset) begin      // synchronous reset
        if (reset) begin
            state            <= IDLE;           
            tx_reg           <= 1'b1;
            tx_done_reg      <= 1'b0;
            br_cnt_reg       <= 0;
            data_bit_cnt_reg <= 0;
            data_tmp_reg     <= 0;
        end else begin
            state            <= state_next;
            tx_reg           <= tx_next;
            tx_done_reg      <= tx_done_next;
            br_cnt_reg       <= br_cnt_next;
            data_bit_cnt_reg <= data_bit_cnt_next;
            data_tmp_reg     <= data_tmp_next;
        end
    end


    always @(*) begin
        state_next        = state;
        tx_next           = tx_reg;
        tx_done_next      = tx_done_reg;
        br_cnt_next       = br_cnt_reg;
        data_bit_cnt_next = data_bit_cnt_reg;
        data_tmp_next     = data_tmp_reg;

        case (state)
            IDLE: begin
                tx_done_next = 1'b0;
                tx_next = 1'b1;
                if (start) begin
                    state_next        = START;
                    data_tmp_next     = tx_data;
                    br_cnt_next       = 0;
                    data_bit_cnt_next = 0;
                end
            end

            START: begin                    // transmit start bit    
                tx_next = 1'b0;             // start bit is always 0
                if (br_tick) begin          // on each baudrate tick
                    if (br_cnt_reg == 15) begin     // if baudrate counter reaches 15
                        state_next  = DATA;         // go to DATA state
                        br_cnt_next = 0;            // reset baudrate counter
                    end else begin                      // if baudrate counter is not at 15  
                        br_cnt_next = br_cnt_reg + 1;   // increment baudrate counter
                    end
                end
            end

            DATA: begin                             // transmit data bits
                tx_next = data_tmp_reg[0];          // transmit the least significant bit first
                if (br_tick) begin                  // on each baudrate tick
                    if (br_cnt_reg == 15) begin     // if baudrate counter reaches 15
                        if (data_bit_cnt_reg == 7) begin    // if all 8 bits are transmitted
                            state_next  = STOP;             // go to STOP state
                            br_cnt_next = 0;                // reset baudrate counter
                        end else begin                                      // if not all bits are transmitted
                            data_bit_cnt_next = data_bit_cnt_reg + 1;       // increment data bit count
                            data_tmp_next     = {1'b0, data_tmp_reg[7:1]};  // right shift the data to transmit the next bit
                            br_cnt_next       = 0;                          // reset baudrate counter      
                        end
                    end else begin                      // if baudrate counter is not at 15
                        br_cnt_next = br_cnt_reg + 1;   // increment baudrate counter
                    end
                end
            end

            STOP: begin                       // transmit stop bit
                tx_next = 1'b1;         // stop bit is always 1
                if (br_tick) begin      // on each baudrate tick
                    if (br_cnt_reg == 15) begin // if baudrate counter reaches 15
                        tx_done_next = 1'b1;    // set transmission done signal
                        state_next   = IDLE;    // go back to IDLE state
                    end else begin                      // if baudrate counter is not at 15  
                        br_cnt_next = br_cnt_reg + 1;   // increment baudrate counter
                    end
                end
            end
        endcase
    end

endmodule


module receiver (
    input clk,
    input reset,
    input br_tick,
    input rx,

    output [7:0] rx_data,
    output rx_done
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3; // states for the FSM

    reg [1:0] state, state_next;            // state register and next state
    reg [7:0] rx_data_reg, rx_data_next;    // register for received data
    reg rx_done_reg, rx_done_next;          // register for reception done signal
    reg [4:0]   
        br_cnt_reg,                         // register for baudrate counter with 16x oversampling
        br_cnt_next;                        // next value for baudrate counter
    reg [2:0]
        data_bit_cnt_reg,                   // register for counting data bits received
        data_bit_cnt_next;                  // next value for data bit count    


    assign rx_data = rx_data_reg;
    assign rx_done = rx_done_reg;


    always @(posedge clk, posedge reset) begin      // synchronous reset
        if (reset) begin                    // reset the state machine and registers
            state            <= IDLE;       
            rx_data_reg      <= 0;
            rx_done_reg      <= 1'b0;
            br_cnt_reg       <= 0;
            data_bit_cnt_reg <= 0;
        end else begin
            state            <= state_next;
            rx_data_reg      <= rx_data_next;
            rx_done_reg      <= rx_done_next;
            br_cnt_reg       <= br_cnt_next;
            data_bit_cnt_reg <= data_bit_cnt_next;
        end
    end


    always @(*) begin           // combinational logic for next state
        state_next = state;
        br_cnt_next = br_cnt_reg;
        data_bit_cnt_next = data_bit_cnt_reg;
        rx_data_next = rx_data_reg;
        rx_done_next = rx_done_reg;

        case (state)
            IDLE: begin
                rx_done_next = 1'b0;
                if (rx == 1'b0) begin
                    br_cnt_next       = 0;
                    data_bit_cnt_next = 0;
                    rx_data_next      = 0;
                    state_next        = START;
                end
            end

            START: begin                // wait for start bit
                if (br_tick) begin              // on each baudrate tick
                    if (br_cnt_reg == 7) begin  // if baudrate counter reaches 7
                        br_cnt_next = 0;        // reset baudrate counter
                        state_next  = DATA;     // go to DATA state
                    end else begin                      // if baudrate counter is not at 7   
                        br_cnt_next = br_cnt_reg + 1;   // increment baudrate counter
                    end
                end
            end

            DATA: begin           // receive data bits
                if (br_tick) begin                              // on each baudrate tick
                    if (br_cnt_reg == 15) begin                 // if baudrate counter reaches 15
                        br_cnt_next  = 0;                       // reset baudrate counter
                        rx_data_next = {rx, rx_data_reg[7:1]};  // shift in the received bit
                        if (data_bit_cnt_reg == 7) begin    // if all 8 bits are received
                            state_next  = STOP;             // go to STOP state
                            br_cnt_next = 0;                // reset baudrate counter
                        end else begin                                  // if not all bits are received  
                            data_bit_cnt_next = data_bit_cnt_reg + 1;   // increment data bit count
                        end
                    end else begin                      // if baudrate counter is not at 15
                        br_cnt_next = br_cnt_next + 1;  // increment baudrate counter
                    end
                end
            end

            STOP: begin              // wait for stop bit
                if (br_tick) begin         // on each baudrate tick
                    if (br_cnt_reg == 23) begin     // if baudrate counter reaches 23
                        br_cnt_next  = 0;           // reset baudrate counter
                        state_next   = IDLE;        // go back to IDLE state
                        rx_done_next = 1'b1;        // set reception done signal
                    end else begin                      // if baudrate counter is not at 23
                        br_cnt_next = br_cnt_reg + 1;   // increment baudrate counter
                    end
                end
            end
        endcase
    end

endmodule