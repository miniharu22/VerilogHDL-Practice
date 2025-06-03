`timescale 1ns / 1ps

`include "transaction.sv"   // Include the transaction class
`include "interface.sv"     // Include the FIFO interface definition

class driver;
    transaction trans;

    // Mailbox to receive transactions from the generator
    mailbox #(transaction) gen2drv_mbox;

    // Virtual interface to the FIFO interface
    virtual fifo_interface fifo_intf;

    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual fifo_interface fifo_intf);
        this.fifo_intf = fifo_intf;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    task reset();
        fifo_intf.wr_en <= 1'b0;
        fifo_intf.wdata <= 0;
        fifo_intf.rd_en <= 1'b0;
        fifo_intf.reset <= 1'b1;
        repeat (5) @(posedge fifo_intf.clk);
        fifo_intf.reset <= 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);        // Receive a transaction from the generator
            fifo_intf.wr_en = trans.wr_en;  // Set write enable signal
            fifo_intf.wdata = trans.wdata;  // Set write data signal
            fifo_intf.rd_en = trans.rd_en;  // Set read enable signal

            trans.display("DRV");
            @(posedge fifo_intf.clk);       // Wait for the next clock cycle
        end
    endtask
endclass