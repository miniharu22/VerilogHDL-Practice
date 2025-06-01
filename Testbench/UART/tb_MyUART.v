`timescale 1ns / 1ps

module tb_MyUART ();
    reg        clk;
    reg        reset;
    reg        tx_start;
    reg  [7:0] tx_data;
    // reg        rx;

    wire       tx;
    wire       tx_done;
    wire [7:0] rx_data;
    wire       rx_done;

    MyUART dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx(tx),

        .tx(tx),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        tx_start = 1'b0;
        // rx = 1'b1;
    end

    initial begin
        #20 reset = 1'b0;
        #100 tx_data = 8'b11000101;
        tx_start = 1'b1;
        #10 tx_start = 1'b0;
    end
endmodule