`ifndef __TRANSACTION_SV_
`define __TRANSACTION_SV_

`timescale 1ns / 1ps

class transaction;
    rand bit       wr_en;
    bit            full;
    rand bit [7:0] wdata;

    rand bit       rd_en;
    bit            empty;
    logic      [7:0] rdata;

    // Ensure that only one operation (write or read) is active at a time
    constraint c_oper {wr_en != rd_en;} 
    constraint c_wr_en {    // Write enable must be 1 when writing
        wr_en dist {    // 50% chance of being 1, 50% chance of being 0
            1 :/ 50,
            0 :/ 50
        };
    }

    task display(string name);
        $display(
            "[%s] wr_en: %x, wdata: %x, full: %x  ||  rd_en: %x, rdata: %x, empty: %x",
            name, wr_en, wdata, full, rd_en, rdata, empty);
    endtask
endclass


`endif