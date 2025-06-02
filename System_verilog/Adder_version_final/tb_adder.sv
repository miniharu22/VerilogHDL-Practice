`timescale 1ns / 1ps

interface adder_intf;   // Interface for adder module
    logic       clk;
    logic       reset;
    logic       valid;
    logic [3:0] a;
    logic [3:0] b;

    logic [3:0] sum;
    logic       carry;
endinterface


class transaction;          // Class to represent a transaction
    rand logic [3:0] a;     // Randomized input values
    rand logic [3:0] b;     // Randomized input values
    logic [3:0] sum;  // Sum of inputs
    logic carry; // Carry output

    task display(string name);
        $display("[%s] a:%d, b:%d, carry:%d, sum:%d", name, a, b, carry, sum);
    endtask

endclass


class generator;    // Class to generate random transactions
    transaction trans; // Instance of transaction class

    // Mailbox to communicate with driver
    // The mailbox allows the generator to send transactions to the driver
    mailbox #(transaction) gen2drv_mbox_gen;    

    event genNextEvent_gen; // Event to signal the next transaction generation

    function new();  // Constructor for generator class
        trans = new();  // Create a new transaction instance
    endfunction

    task run();     // Task to generate random transactions
        repeat (1000) begin   // Generate 10 transactions
            assert (trans.randomize())  // Randomize the transaction
            else $error("trans.randomize() error!"); // Check if randomization was successful

            gen2drv_mbox_gen.put(trans); // Put the transaction into the mailbox   
            trans.display("GEN");  // Display the transaction details
            @(genNextEvent_gen); // Wait for the next event to signal generation
        end
    endtask

endclass


class driver;   // Class to drive the adder interface
    virtual adder_intf drv_adder_intf;    // Virtual interface to the adder
                                    // This allows the driver to interact with the adder module
    
    // Mailbox to receive transactions from the generator   
    mailbox #(transaction) gen2drv_mbox_drv;
    transaction trans; // Instance of transaction class to access the transaction data

    //event genNextEvent_drv; // Event to signal the next transaction processing
    event monNextEvent_drv; // Event to signal the next monitoring event

    function new(virtual adder_intf adder_if2);  // Constructor for driver class
        this.drv_adder_intf = adder_if2;   // Initialize the virtual interface
    endfunction

    task reset();               // Task to reset the adder interface
        drv_adder_intf.a     = 0;     // Reset input a
        drv_adder_intf.b     = 0;     // Reset input b
        drv_adder_intf.valid = 1'b0;  // Reset valid signal
        drv_adder_intf.reset = 1'b1;  // Set reset signal high
        repeat (5) @(drv_adder_intf.clk); // Wait for 5 clock cycles
        drv_adder_intf.reset = 1'b0;  // Set reset signal low
    endtask

    task run();     // Task to run the driver
        forever begin   // Infinite loop to continuously process transactions
            
            gen2drv_mbox_drv.get(trans);   // Get a transaction from the mailbox
            // This blocks until a transaction is available
            // blocking code -> waits for a transaction to be available

            drv_adder_intf.a     = trans.a;      // Set input a from the transaction
            drv_adder_intf.b     = trans.b;      // Set input b from the transaction
            drv_adder_intf.valid = 1'b1;      // Set valid signal high to indicate inputs are ready
            trans.display("DRV");          // Display the transaction details
            @(posedge drv_adder_intf.clk);    // Wait for the next clock edge
            drv_adder_intf.valid = 1'b0;      // Set valid signal low to indicate inputs are no longer valid
            @(posedge drv_adder_intf.clk);    // Wait for the next clock edge to allow the adder to process the inputs
            -> monNextEvent_drv; // Signal the next transaction processing event
            //-> genNextEvent_drv; // Signal the next monitoring event
        end
    endtask

endclass

class monitor;  // Change DUT output signals to transaction class
    virtual adder_intf adder_intf_mon;          // Virtual interface to the adder for monitoring
    mailbox #(transaction) mon2scb_mbox_mon;    // Mailbox to send transactions to the scoreboard
    transaction trans;
    event monNextEvent_mon;

    // Constructor for monitor class
    // It initializes the virtual interface and creates a new transaction instance
    function new(virtual adder_intf adder_if2); 
        this.adder_intf_mon = adder_if2;
        trans = new();                          
    endfunction

    task run();
        forever begin
            @(monNextEvent_mon);    // Wait for the next monitoring event
            trans.a     = adder_intf_mon.a;
            trans.b     = adder_intf_mon.b;
            trans.sum   = adder_intf_mon.sum;
            trans.carry = adder_intf_mon.carry;
            mon2scb_mbox_mon.put(trans);
            trans.display("MON");
        end
    endtask

endclass

class scoreboard;  // Class to verify the correctness of the adder outputs
    // Mailbox to receive transactions from the monitor
    mailbox #(transaction) mon2scb_mbox_sb; 
    transaction trans;
    event genNextEvent_sb;

    // Counters for total, pass, and fail transactions
    int total_cnt, pass_cnt, fail_cnt; 

    // Initialize the counters
    function new(); 
        total_cnt = 0;
        pass_cnt  = 0;
        fail_cnt  = 0;
    endfunction

    task run();
        forever begin
            mon2scb_mbox_sb.get(trans); // Get a transaction from the mailbox
            trans.display("SCB");
            // Check if the sum and carry match the expected values
            // The expected sum is the sum of inputs a and b
            if ((trans.a + trans.b) == {trans.carry, trans.sum}) begin
                $display(" ---> PASS ! %d + %d = %d", trans.a, trans.b, {
                         trans.carry, trans.sum});
                         pass_cnt++; // Increment pass counter
            end else begin
                $display(" ---> FAIL ! %d + %d = %d", trans.a, trans.b, {
                         trans.carry, trans.sum});
                         fail_cnt++; // Increment fail counter
            end
            total_cnt++; // Increment total counter
        -> genNextEvent_sb; // Signal the next scoreboard event
        end
    endtask
endclass



module tb_adder ();

    adder_intf adder_intface ();     // Instantiate the adder interface
    generator gen;  // Instance of generator class to generate
    driver drv;     // Instance of driver class to drive the adder interface
    monitor mon;    // Instance of monitor class to monitor the adder outputs
    scoreboard scb; // Instance of scoreboard class to verify outputs

    event genNextEvent; // Event to signal the next transaction generation
    event monNextEvent; // Event to signal the next monitoring event

    // Mailbox to communicate between generator and driver
    mailbox #(transaction) gen2drv_mbox; 
    // Mailbox to communicate between monitor and scoreboard
    mailbox #(transaction) mon2scb_mbox;
    

    adder dut (
        .clk(adder_intface.clk),  
        .reset(adder_intface.reset),
        .valid(adder_intface.valid),
        .a(adder_intface.a),
        .b(adder_intface.b),

        .sum  (adder_intface.sum),
        .carry(adder_intface.carry)
    );

    always #5 adder_intface.clk = ~adder_intface.clk;

    initial begin
        adder_intface.clk   = 1'b0;
        adder_intface.reset = 1'b1;
    end

    initial begin
        gen2drv_mbox = new();   // Create a new mailbox for communication
        mon2scb_mbox = new();   // Create a new mailbox for monitoring

        gen = new();              // Create a new generator instance
        drv = new(adder_intface); // Create a new driver instance with the adder interface
        mon = new(adder_intface); // Create a new monitor instance with the adder interface
        scb = new();              // Create a new scoreboard instance

        // Connect the gen event & drv event & mon event
        gen.genNextEvent_gen = genNextEvent; 
        scb.genNextEvent_sb = genNextEvent; 
        mon.monNextEvent_mon = monNextEvent;
        drv.monNextEvent_drv = monNextEvent;
        
        // Connect the generator's mailbox to the driver's mailbox
        gen.gen2drv_mbox_gen = gen2drv_mbox;
        // Connect the driver's mailbox to the generator's mailbox
        drv.gen2drv_mbox_drv = gen2drv_mbox;    
        // Connect the monitor's mailbox to the scoreboard's mailbox
        mon.mon2scb_mbox_mon = mon2scb_mbox;
        // Connect the scoreboard's mailbox to the monitor's mailbox
        scb.mon2scb_mbox_sb = mon2scb_mbox; 

        drv.reset();    // Reset the adder interface

        fork
            gen.run();  // Start the generator to produce transactions
            drv.run();  // Start the driver to process transactions
            mon.run();  // Start the monitor to observe the adder outputs
            scb.run();  // Start the scoreboard to verify outputs
        join_any

        $display("==========================");
        $display("==     Final Report    ==");
        $display("==========================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("==========================");
        $display("== test bench is finished! ==");
        $display("==========================");
        #10 $finish;
    end

endmodule

