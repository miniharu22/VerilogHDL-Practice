`timescale 1ns / 1ps

`include "transaction.sv"   // Include the transaction class
`include "interface.sv"     // Include the FIFO interface definition

class monitor;
    transaction trans;

    // Mailbox to send transactions to the scoreboard
    mailbox #(transaction) mon2scb_mbox;

    // Virtual interface to the FIFO interface
    virtual fifo_interface fifo_intf;

    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual fifo_interface fifo_intf);
        this.mon2scb_mbox = mon2scb_mbox;
        this.fifo_intf = fifo_intf;
    endfunction

    task run();
        forever begin
            trans = new(); // Create a new transaction object
            #1; // Delay to ensure the transaction is ready
            trans.wr_en = fifo_intf.wr_en;  // Get the write enable signal
            trans.rd_en = fifo_intf.rd_en;  // Get the read enable signal
            trans.wdata = fifo_intf.wdata;  // Get the write data signal
            trans.rdata = fifo_intf.rdata;  // Get the read data signal

            @(posedge fifo_intf.clk);       // Wait for the next clock cycle
            trans.full  = fifo_intf.full;   // Get the FIFO full signal
            trans.empty = fifo_intf.empty;  // Get the FIFO empty signal

            mon2scb_mbox.put(trans);    // Send the transaction to the scoreboard
            trans.display("MON");
        end
    endtask
endclass