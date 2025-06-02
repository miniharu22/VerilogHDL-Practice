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

    task display(string name);
        $display("[%s] a:%d, b:%d", name, a, b);
    endtask

endclass


class generator;    // Class to generate random transactions
    transaction tr; // Instance of transaction class

    // Mailbox to communicate with driver
    // The mailbox allows the generator to send transactions to the driver
    mailbox #(transaction) gen2drv_mbox;    

    event genNextEvent1; // Event to signal the next transaction generation

    function new();  // Constructor for generator class
        tr = new();  // Create a new transaction instance
    endfunction

    task run();     // Task to generate random transactions
        repeat (10) begin   // Generate 10 transactions
            assert (tr.randomize())  // Randomize the transaction
            else $error("tr.randomize() error!"); // Check if randomization was successful

            gen2drv_mbox.put(tr); // Put the transaction into the mailbox   
            tr.display("GEN");  // Display the transaction details
            @(genNextEvent1); // Wait for the next event to signal generation
        end
    endtask

endclass


class driver;   // Class to drive the adder interface
    virtual adder_intf adder_if;    // Virtual interface to the adder
                                    // This allows the driver to interact with the adder module
    
    // Mailbox to receive transactions from the generator   
    mailbox #(transaction) gen2drv_mbox;
    transaction tr; // Instance of transaction class to access the transaction data

    event genNextEvent2; // Event to signal the next transaction processing

    function new(virtual adder_intf adder_if);  // Constructor for driver class
        this.adder_if = adder_if;   // Initialize the virtual interface
    endfunction

    task reset();               // Task to reset the adder interface
        adder_if.a     = 0;     // Reset input a
        adder_if.b     = 0;     // Reset input b
        adder_if.valid = 1'b0;  // Reset valid signal
        adder_if.reset = 1'b1;  // Set reset signal high
        repeat (5) @(adder_if.clk); // Wait for 5 clock cycles
        adder_if.reset = 1'b0;  // Set reset signal low
    endtask

    task run();     // Task to run the driver
        forever begin   // Infinite loop to continuously process transactions
            
            gen2drv_mbox.get(tr);   // Get a transaction from the mailbox
            // This blocks until a transaction is available
            // blocking code -> waits for a transaction to be available

            adder_if.a     = tr.a;      // Set input a from the transaction
            adder_if.b     = tr.b;      // Set input b from the transaction
            adder_if.valid = 1'b1;      // Set valid signal high to indicate inputs are ready
            tr.display("DRV");          // Display the transaction details
            @(posedge adder_if.clk);    // Wait for the next clock edge
            adder_if.valid = 1'b0;      // Set valid signal low to indicate inputs are no longer valid
            @(posedge adder_if.clk);    // Wait for the next clock edge to allow the adder to process the inputs
            $display("Sum: %d, Carry: %d", adder_if.sum, adder_if.carry); // Display the results
            -> genNextEvent2; // Signal the next transaction processing event
        end
    endtask

endclass


module tb_adder ();

    adder_intf adder_if ();     // Instantiate the adder interface
    generator gen;  // Instance of generator class to generate
    driver drv;     // Instance of driver class to drive the adder interface
    
    event genNextEvent; // Event to signal the next transaction generation

    mailbox #(transaction) gen2drv_mbox; 
    // Mailbox to communicate between generator and driver

    adder dut (
        .clk(adder_if.clk),  
        .reset(adder_if.reset),
        .valid(adder_if.valid),
        .a(adder_if.a),
        .b(adder_if.b),

        .sum  (adder_if.sum),
        .carry(adder_if.carry)
    );

    always #5 adder_if.clk = ~adder_if.clk;

    initial begin
        adder_if.clk   = 1'b0;
        adder_if.reset = 1'b1;
    end

    initial begin
        gen2drv_mbox = new();   // Create a new mailbox for communication

        gen = new();         // Create a new generator instance
        drv = new(adder_if); // Create a new driver instance with the adder interface
        
        // Connect the gen event  & drv event
        gen.genNextEvent1 = genNextEvent; 
        drv.genNextEvent2 = genNextEvent; 
        
        
        // Connect the generator's mailbox to the driver's mailbox
        gen.gen2drv_mbox = gen2drv_mbox;
        // Connect the driver's mailbox to the generator's mailbox
        drv.gen2drv_mbox = gen2drv_mbox;    

        drv.reset();    // Reset the adder interface

        fork
            gen.run();  // Start the generator to produce transactions
            drv.run();  // Start the driver to process transactions
        join
        #10 $finish;
    end

endmodule

