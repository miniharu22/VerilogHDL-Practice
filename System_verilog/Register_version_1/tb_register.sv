`timescale 1ns / 1ps

interface reg_interface; // Interface for register module
    logic clk;
    logic reset;
    logic [31:0] D;

    logic [31:0] Q;
endinterface


class transaction;
    rand logic [31:0] data;
    logic      [31:0] out;

    task display(string name);
        $display("[%s] data: %x, out: %x", name, data, out);
    endtask
endclass


class generator;        // Class to generate random transactions
    transaction trans;  // Instance of transaction class

    // Mailbox to communicate with driver
    mailbox #(transaction) gen2drv_mbox;

    event gen_next_event; // Event to signal the next generation

    // Constructor to initialize mailbox and event
    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox   = gen2drv_mbox;     // Initialize mailbox
        this.gen_next_event = gen_next_event;   // Initialize event
    endfunction

    task run(int count);        // Task to generate random transactions
        repeat (count) begin
            // Create a new transaction instance inside the run task
            // transaction class instance data is automatically organized in the memory by Garbage Collector    
            trans = new();       

            assert (trans.randomize())
            else $error("[GEN] trans.randomize() error!");

            gen2drv_mbox.put(trans);    // Put the transaction into the mailbox
            trans.display("GEN");
            @(gen_next_event);  // Wait for the next event to continue
        end
    endtask
endclass


class driver;
    transaction trans;  // Instance of transaction class

    // Mailbox to receive transactions from generator
    mailbox #(transaction) gen2drv_mbox;    

     // Virtual interface to interact with the register
    virtual reg_interface reg_intf;

    // Constructor to initialize mailbox and virtual interface
    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual reg_interface reg_intf);
        this.gen2drv_mbox   = gen2drv_mbox; // Initialize mailbox
        this.reg_intf       = reg_intf;     // Initialize virtual interface
    endfunction

    task reset();
        reg_intf.D     <= 0;
        reg_intf.reset <= 1'b1;
        repeat (5) @(posedge reg_intf.clk);
        reg_intf.reset <= 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);    // Get the transaction from the mailbox
            reg_intf.D <= trans.data;   // Set the data to the register interface

            trans.display("DRV");       
            @(posedge reg_intf.clk);    
        end
    endtask
endclass


class monitor;
    transaction trans;
     // Mailbox to send transactions to scoreboard
    mailbox #(transaction) mon2scb_mbox;   

    // Virtual interface to interact with the register module 
    virtual reg_interface reg_intf;

    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual reg_interface reg_intf);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.reg_intf       = reg_intf;
    endfunction

    task run();
        forever begin
            trans = new();  // Create a new transaction instance

            @(posedge reg_intf.clk);    // Wait for the clock edge
            trans.data = reg_intf.D;    // Capture the data from the register interface

            @(posedge reg_intf.clk);    // Wait for the next clock edge
            trans.out  = reg_intf.Q;    // Capture the output from the register interface

            mon2scb_mbox.put(trans);    // Send the transaction to the scoreboard
            trans.display("MON");       
        end
    endtask
endclass


class scoreboard;
    transaction trans;

    // Mailbox to receive transactions from monitor
    mailbox #(transaction) mon2scb_mbox;
    // Event to signal the next generation of transactions
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt;

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox; 
        this.gen_next_event = gen_next_event;
        total_cnt           = 0;
        pass_cnt            = 0;
        fail_cnt            = 0;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(trans);    // Get the transaction from the mailbox
            trans.display("SCB");

            if (trans.data == trans.out) begin
                $display(" ---> PASS! %x == %x", trans.data, trans.out);
                pass_cnt++;
            end else begin
                $display(" ---> FAIL! %x != %x", trans.data, trans.out);
                fail_cnt++;
            end
            total_cnt++;

            ->gen_next_event;   // Signal the next generation of transactions
        end
    endtask
endclass


class environment;  // Environment class to encapsulate the entire testbench
                    // Instances of various components in the environment 
                    // Initializes the generator, driver, monitor, and scoreboard      
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;    // Mailbox for generator to driver communication
    mailbox #(transaction) mon2scb_mbox;    // Mailbox for monitor to scoreboard communication

    event gen_next_event;   // Event to signal the next generation of transactions

    function new(virtual reg_interface reg_intf);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, reg_intf);
        mon = new(mon2scb_mbox, reg_intf);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction


    task report();
        $display("=============================");
        $display("==       Final Report      ==");
        $display("=============================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("=============================");
        $display("== test bench is finished! ==");
        $display("=============================");
    endtask


    task pre_run();         // Task to reset the environment before running the test
        drv.reset();    
    endtask

    task run();
        fork
            gen.run(100);   // Run the generator to create 100 transactions
            drv.run();
            mon.run();
            scb.run();
        join_any

        report();
        #10 $finish;
    endtask

    task run_test();
        pre_run();
        run();
    endtask
endclass


module tb_register ();
    environment env;
    reg_interface reg_intf (); 

    register dut (
        .clk(reg_intf.clk),
        .reset(reg_intf.reset),
        .D(reg_intf.D),

        .Q(reg_intf.Q)
    );

    always #5 reg_intf.clk = ~reg_intf.clk;

    initial begin
        reg_intf.clk = 0;
    end

    initial begin
        env = new(reg_intf);
        env.run_test();
    end

endmodule