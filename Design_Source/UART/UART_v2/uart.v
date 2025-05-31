`timescale 1ns / 1ps

module uart (
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,

    output tx,
    output tx_done
);

    wire w_br_tick;

    baudrate_generator U_BR_Gen (
        .clk  (clk),
        .reset(reset),

        .br_tick(w_br_tick)
    );


    transmitter U_TxD (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .br_tick(w_br_tick),
        .tx_data(tx_data),

        .tx(tx),
        .tx_done(tx_done)
    );

endmodule


module baudrate_generator (
    input clk,
    input reset,

    output br_tick
);
    // The baudrate generator counts clock cycles 
    // to generate a tick at the specified baudrate.
    reg [$clog2(100_000_000/9600)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign br_tick = tick_reg;

    always @(posedge clk, posedge reset) begin  // synchronous reset
        if (reset) begin        // reset the counter and tick
            counter_reg <= 0;   // reset counter
            tick_reg <= 1'b0;   // reset tick
        end else begin                      // update counter and tick      
            counter_reg <= counter_next;    // update counter
            tick_reg <= tick_next;          // update tick
        end
    end

    always @(*) begin   // combinational logic for next state
        counter_next = counter_reg; // default next state is current state
        if (counter_reg == $clog2(100_000_000 / 9600) - 1) begin // if counter reached the limit
            counter_next = 0;   // reset counter
            tick_next = 1'b1;   // set tick to 1
        end else begin                      // if counter not reached the limit
            counter_next = counter_reg + 1; // increment counter
            tick_next = 1'b0;               // set tick to 0
        end
    end
endmodule


module transmitter (
    input clk,
    input reset,
    input tx_start,
    input br_tick,
    input [7:0] tx_data,

    output tx,
    output tx_done
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [7:0] tx_data_reg, tx_data_next;
    reg [1:0] state, state_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg tx_reg, tx_next, tx_done_reg, tx_done_next;


    // state rigister
    always @(posedge clk, posedge reset) begin // synchronous reset
        if (reset) begin            // reset state and registers
            state <= IDLE;          // reset state to IDLE
            tx_data_reg <= 7'b0;    // reset data register
            bit_cnt_reg <= 3'd0;    // reset bit counter
            tx_reg <= 1'b1;         // reset tx line to idle state (1)
            tx_done_reg <= 1'b0;    // reset tx done flag
        end else begin                   // update state and registers  
            state <= state_next;         // update state
            tx_data_reg <= tx_data_next; // update data register
            bit_cnt_reg <= bit_cnt_next; // update bit counter
            tx_reg <= tx_next;           // update tx line
            tx_done_reg <= tx_done_next; // update tx done flag
        end
    end


    // next state logic
    always @(*) begin               // combinational logic for next state
        state_next = state;         // default next state is current state
        tx_done_next = tx_done_reg; // default tx done is current state
        tx_data_next = tx_data_reg; // default next data is current data
        tx_next = tx_reg;           // default next tx is current tx
        bit_cnt_next = bit_cnt_reg; // default next bit count is current bit count

        case (state)    // state machine for transmitter
            IDLE: begin // IDLE state
                tx_next = 1'b1;     
                tx_done_next = 1'b0;
                if (tx_start) begin         // if tx_start is high
                    tx_data_next = tx_data; // load data to transmit
                    bit_cnt_next = 0;       // reset bit counter
                    state_next   = START;   // go to START state
                end
            end

            START: begin        // START state  
                tx_next = 1'b0; // set tx line to low (start bit)
                if (br_tick) state_next = DATA; // go to DATA state after baudrate tick
            end

            DATA: begin                     // DATA state
                tx_next = tx_data_reg[0];   // transmit the current bit
                if (br_tick) begin              // if baudrate tick
                    if (bit_cnt_reg == 7) begin // if all bits are transmitted
                        state_next = STOP;      // go to STOP state
                    end else begin                                // if not all bits are transmitted  
                        bit_cnt_next = bit_cnt_reg + 1;           // increment bit counter
                        tx_data_next = {1'b0, tx_data_reg[7:1]};  // shift data register to the right
                    end
                end
            end

            STOP: begin       // STOP state
                tx_next = 1'b1;             // set tx line to high (stop bit)
                if (br_tick) begin          // if baudrate tick
                    state_next   = IDLE;    // go back to IDLE state
                    tx_done_next = 1'b1;    // set tx done flag
                end
            end

        endcase

    end


    // output logic
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

endmodule