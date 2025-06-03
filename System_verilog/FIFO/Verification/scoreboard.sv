`timescale 1ns / 1ps

`include "transaction.sv"   // Include the transaction class

class scoreboard;
    transaction trans;

    // Mailbox to receive transactions from the monitor
    mailbox #(transaction) mon2scb_mbox;

    // Event to signal the next transaction generation
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt, write_cnt, full_cnt, empty_cnt;
    reg [7:0] scb_fifo[$];      // FIFO to store data for comparison
    reg [7:0] scb_fifo_data;    // Variable to hold data read from the FIFO
    int max = 8;                // Maximum size of the FIFO

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.gen_next_event = gen_next_event;

        total_cnt           = 0;
        pass_cnt            = 0;
        fail_cnt            = 0;
        write_cnt           = 0;
        full_cnt = 0;
        empty_cnt = 0;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(trans);    // Receive a transaction from the monitor
            trans.display("SCB");

            if (trans.wr_en) begin  // If write enable is set
                if (scb_fifo.size() < max) begin        // Check if FIFO is not full
                    scb_fifo.push_back(trans.wdata);    // Write data to the FIFO
                    $display(" ---> WRITE! fifo_data %x, queue size: %x, %p\n",
                             trans.wdata, scb_fifo.size(), scb_fifo);
                    write_cnt++;    // Increment write count
                end else begin      // If FIFO is full, display an error message
                    $display(" ---> FIFO FULL! Cannot write data. fifo_data %x, queue size: %x, %p\n",
                             trans.wdata, scb_fifo.size(), scb_fifo);
                             full_cnt++;
                end

            end else if (trans.rd_en) begin // If read enable is set
                if (scb_fifo.size() > 0) begin  // Check if FIFO is not empty
                    scb_fifo_data = scb_fifo.pop_front();  // Read data from the FIFO

                    if (scb_fifo_data == trans.rdata) begin // Compare FIFO data with read data
                        $display(" ---> PASS! fifo_data %x == rdata %x, queue size: %x, %p\n",
                                 scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
                        pass_cnt++; // Increment pass count
                    end else begin 
                        $display(" ---> FAIL! fifo_data %x != rdata %x, queue size: %x, %p\n",
                                 scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
                        fail_cnt++;
                    end
                end else begin  //
                    $display(" ---> FIFO EMPTY! Cannot read data.");
                    empty_cnt++;
                end

            end
            total_cnt++;
            ->gen_next_event; // Signal the next transaction generation
        end
    endtask
endclass