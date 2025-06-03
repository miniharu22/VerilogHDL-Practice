`timescale 1ns / 1ps

`include "transaction.sv"   // Include the transaction class
`include "generator.sv"     // Include the generator class
`include "driver.sv"        // Include the driver class
`include "monitor.sv"       // Include the monitor class
`include "scoreboard.sv"    // Include the scoreboard class
`include "interface.sv"     // Include the FIFO interface definition


  class environment;  
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    mailbox #(transaction) gen2drv_mbox;    // Mailbox to send transactions from generator to driver
    mailbox #(transaction) mon2scb_mbox;    // Mailbox to send transactions from monitor to scoreboard

    event                  gen_next_event;  // Event to signal the next transaction generation

    function new(virtual fifo_interface fifo_intf);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, fifo_intf);
        mon = new(mon2scb_mbox, fifo_intf);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction


    task report();
        $display("=============================");
        $display("==       Final Report      ==");
        $display("=============================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("Write Count : %d", scb.write_cnt);
        $display("FULL Count : %d", scb.full_cnt);
        $display("EMPTY Count : %d", scb.empty_cnt);
        $display("=============================");
        $display("== test bench is finished! ==");
        $display("=============================");
    endtask


    task pre_run();
        drv.reset();
    endtask

    task run(int count);
        fork
            gen.run(count);
            drv.run();
            mon.run();
            scb.run();
        join_any

        report();
        #10 $finish;
    endtask

    task run_test(int count);
        pre_run();
        run(count);
    endtask
endclass