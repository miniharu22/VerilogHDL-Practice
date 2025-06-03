`timescale 1ns / 1ps

interface ram_interface;
    logic       clk;
    logic       wr_en;
    logic [9:0] addr;
    logic [7:0] wdata;

    logic [7:0] rdata;
endinterface


class transaction;          
    rand bit       wr_en;   // bit : 2state type
    rand bit [9:0] addr;
    rand bit [7:0] wdata;
    bit      [7:0] rdata;

    task display(string name);
        $display("[%s] wr_en: %x, addr: %x, wdata: %x, rdata: %x", name, wr_en,
                 addr, wdata, rdata);
    endtask

    // Constaints -> able to set randomization rules regardless with name
    constraint c_addr {addr inside {[10:19]};}   // addr: 10 ~ 19
    constraint c_wdata1 {wdata < 100;}           // wdata: 0 ~ 99
    constraint c_wdata2 {wdata > 10;}            // wdata: 11 ~ 255

    constraint c_wr_en {wr_en dist {0:/80, 1:/20};} // wr_en: 0 ~ 80%, 1 ~ 20%
endclass


class generator;
    transaction            trans;

    // mailbox: communication channel between generator and driver
    mailbox #(transaction) gen2drv_mbox;

    // event: used to synchronize between generator and scoreboard
    event                  gen_next_event;

    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.gen_next_event = gen_next_event;

    endfunction

    task run(int count);
        repeat(count) begin     /*Rransaction class instance data is automatically
                                  organized by garbage collection*/
                                // So, Memory Leak is not a problem 
            trans = new();
            assert (trans.randomize())
            else $error("[GEN] trans.radomize() error!");
            gen2drv_mbox.put(trans);
            trans.display("GEN");
            @(gen_next_event);  // Wait for scoreboard to finish processing
        end
    endtask
endclass


class driver;
    transaction trans;

    // mailbox: communication channel between generator and driver
    mailbox #(transaction) gen2drv_mbox;

    // virtual interface: used to access the RAM interface
    virtual ram_interface ram_intf;

    function new(virtual ram_interface ram_intf,
                 mailbox#(transaction) gen2drv_mbox);
        this.ram_intf = ram_intf;
        this.gen2drv_mbox = gen2drv_mbox;

    endfunction

    task reset ();      // Reset the RAM interface
        ram_intf.wr_en <= 0;
        ram_intf.addr  <= 0;
        ram_intf.wdata <= 0;
        repeat (5) @(posedge ram_intf.clk);
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);        // Get transaction from generator
            ram_intf.wr_en <= trans.wr_en;  // Set write enable signal
            ram_intf.addr  <= trans.addr;   // Set address signal
            ram_intf.wdata <= trans.wdata;  // Set write data signal

            trans.display("DRV");
            @(posedge ram_intf.clk);
        end
    endtask
endclass


class monitor;
    transaction trans;

    // mailbox: communication channel between monitor and scoreboard
    mailbox #(transaction) mon2scb_mbox;

    // virtual interface: used to access the RAM interface
    virtual ram_interface ram_intf;

    function new(virtual ram_interface ram_intf,
                 mailbox#(transaction) mon2scb_mbox);
        this.ram_intf = ram_intf;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        forever begin
            trans = new();
            @(posedge ram_intf.clk);
            trans.wr_en = ram_intf.wr_en;   // Capture write enable signal
            trans.addr  = ram_intf.addr;    // Capture address signal
            trans.wdata = ram_intf.wdata;   // Capture write data signal
            trans.rdata = ram_intf.rdata;   // Capture read data signal

            mon2scb_mbox.put(trans);   // Put transaction into mailbox for scoreboard
            trans.display("MON");
        end
    endtask
endclass


class scoreboard;
    transaction trans;

    // mailbox: communication channel between monitor and scoreboard
    mailbox #(transaction) mon2scb_mbox;

    // event: used to synchronize between scoreboard and generator
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt, write_cnt;
    logic [7:0] mem[0:2**10-1];     // Memory array to store data

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
        write_cnt = 0;

        for (int i = 0; i < 2 ** 10 - 1; i++) begin
            mem[i] = 0;
        end
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(trans);    // Get transaction from monitor
            trans.display("SCB");
            if (trans.wr_en) begin 
                if (mem[trans.addr] == trans.rdata) begin
                    $display(" --> READ PASS! mem[%x] == %x", mem[trans.addr],
                             trans.rdata);
                    pass_cnt++;
                end else begin
                    $display(" --> READ FAIL! mem[%x] == %x", mem[trans.addr],
                             trans.rdata);
                    fail_cnt++;
                end
            // There is no stored data in Initial Logic mem becaus of its intialization
            // It's the same with reg mem in DUT 
            /* Before writing, they are compared on a condition of 0 == 0
               After writing, the output & storage values are properly visible*/
            
            end else begin  // write operation
                mem[trans.addr] = trans.wdata; // Store data in memory
                $display(" --> WRITE! mem[%x] == %x", trans.addr, trans.wdata);
                write_cnt++; // Increment write count
            end

            total_cnt++;
            ->gen_next_event; // Signal that scoreboard has finished processing
        end
    endtask
endclass


class environment;
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    event                  gen_next_event;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;


    function new(virtual ram_interface ram_intf);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(ram_intf, gen2drv_mbox);
        mon = new(ram_intf, mon2scb_mbox);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction

    task pre_run();
        drv.reset();
    endtask

    task report();
        $display("================================");
        $display("       Final Report       ");
        $display("================================");
        $display("Total Test      : %d", scb.total_cnt);
        $display("READ Pass Count : %d", scb.pass_cnt);
        $display("READ Fail Count : %d", scb.fail_cnt);
        $display("WRITE Count     : %d", scb.write_cnt);
        $display("================================");
        $display("  test bench is finished! ");
        $display("================================");
    endtask


    task run();

        fork
            gen.run(10000);
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


module tb_ram ();
    environment env;
    ram_interface ram_intf ();

    ram dut (
        .clk(ram_intf.clk),
        .address(ram_intf.addr),
        .wdata(ram_intf.wdata),
        .wr_en(ram_intf.wr_en), // Write enable signal

        .rdata(ram_intf.rdata)
    );

    always #5 ram_intf.clk = ~ram_intf.clk;

    initial begin
        ram_intf.clk = 0;
    end

    initial begin
        env = new(ram_intf);
        env.run_test();
    end

endmodule