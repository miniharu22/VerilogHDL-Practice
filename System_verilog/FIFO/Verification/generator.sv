`timescale 1ns / 1ps

`include "transaction.sv"   // Include the transaction class

class generator;
    transaction trans;

    // Mailbox to send transactions to the driver
    mailbox #(transaction) gen2drv_mbox;

    // Event to signal the next transaction generation
    event gen_next_event;

    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int count);
        repeat(count) begin
            trans = new();

            assert(trans.randomize())
            else $error("[GEN] trans.randomize() error!");

            gen2drv_mbox.put(trans); // Send the transaction to the driver
            trans.display("GEN");   
            @(gen_next_event);       // Wait for the next generation event
        end
    endtask
endclass