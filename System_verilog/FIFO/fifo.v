`timescale 1ns / 1ps


module fifo #(
    parameter ADDR_WIDTH = 3,
    DATA_WIDTH = 8
) (
    input clk,
    input reset,

    input                   wr_en,  // write enable
    output                  full,   // full flag
    input  [DATA_WIDTH-1:0] wdata,  // write data

    input                   rd_en,  // read enable
    output                  empty,  // empty flag
    output [DATA_WIDTH-1:0] rdata   // read data
);

    wire w_full;
    wire [ADDR_WIDTH-1:0] w_waddr, w_raddr;

    // Register file module to store data
    register_file #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)  
    ) U_RegFile (
        .clk  (clk),
        .reset(reset),
        .wr_en(wr_en & ~full), // Write enable is active when not full
        .waddr(w_waddr),    // Write address
        .wdata(wdata),      // Write data
        .raddr(w_raddr),    // Read address

        .rdata(rdata)   // Read data
    );

    // FIFO control unit to manage pointers and status
    fifo_control_unit #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) U_FIFO_CU (
        .clk  (clk),
        .reset(reset),

        // wrte
        .wr_en(wr_en),
        .full (full),
        .waddr(w_waddr),

        // read
        .rd_en(rd_en),
        .empty(empty),
        .raddr(w_raddr)
    );

endmodule

module register_file #(
    parameter ADDR_WIDTH = 3,
    DATA_WIDTH = 8  // 3bit address == 2^3 memory locations, 8bit data width   
) (
    input                  clk,
    input                  reset,
    input                  wr_en,
    input [ADDR_WIDTH-1:0] waddr,   // write address
    input [DATA_WIDTH-1:0] wdata,   // write data
    input [ADDR_WIDTH-1:0] raddr,   // read address

    output [DATA_WIDTH-1:0] rdata   // read data
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem[0:2**ADDR_WIDTH];

    // Write operation
    always @(posedge clk) begin         // On clock edge
        if (wr_en) mem[waddr] <= wdata; // Write data to memory at waddr
    end

    // Read operation
    assign rdata = mem[raddr];  // Read data from memory at raddr

endmodule


module fifo_control_unit #(
    parameter ADDR_WIDTH = 3    // 3bit address == 2^3 memory locations
) (
    input clk,
    input reset,

    // wrte
    input                   wr_en,  // write enable
    output                  full,   // full flag
    output [ADDR_WIDTH-1:0] waddr,  // write address

    // read
    input rd_en,                    // read enable
    output empty,                   // empty flag    
    output [ADDR_WIDTH-1:0] raddr   // read address
);

    reg [ADDR_WIDTH-1:0] wr_ptr_reg, wr_ptr_next;   // Write pointer
    reg [ADDR_WIDTH-1:0] rd_ptr_reg, rd_ptr_next;   // Read pointer
    reg full_reg, full_next, empty_reg, empty_next; // Full and empty flags


    assign waddr = wr_ptr_reg;
    assign raddr = rd_ptr_reg;
    assign full  = full_reg;
    assign empty = empty_reg;

    // Sequential logic for pointers and status flags
    always @(posedge clk, posedge reset) begin  
        if (reset) begin
            wr_ptr_reg <= 0;
            rd_ptr_reg <= 0;
            full_reg   <= 1'b0;
            empty_reg  <= 1'b0;
        end else begin                  // On clock edge
            wr_ptr_reg <= wr_ptr_next;  // Update write pointer
            rd_ptr_reg <= rd_ptr_next;  // Update read pointer
            full_reg   <= full_next;    // Update full flag
            empty_reg  <= empty_next;   // Update empty flag
        end
    end

    // Combinational logic for next pointer and status updates
    always @(*) begin
        // Default: keep current state
        wr_ptr_next = wr_ptr_reg;   
        rd_ptr_next = rd_ptr_reg;   
        full_next   = full_reg;
        empty_next  = empty_reg;

        case ({
            wr_en, rd_en
        })
            2'b01: begin  // Read operation
                if (!empty_reg) begin   // If not empty, read data
                    full_next   = 1'b0; // Clear full flag
                    rd_ptr_next = rd_ptr_reg + 1;   // Increment read pointer
                    if (rd_ptr_next == wr_ptr_reg) begin  // If read pointer meets write pointer
                        empty_next = 1'b1;  // Set empty flag
                    end
                end
            end

            2'b10: begin  // Write operation
                if (!full_reg) begin    // If not full, write data
                    empty_next  = 1'b0; // Clear empty flag
                    wr_ptr_next = wr_ptr_reg + 1;   // Increment write pointer
                    if (wr_ptr_next == rd_ptr_reg) begin  // If write pointer meets read pointer   
                        full_next = 1'b1;   // Set full flag
                    end
                end
            end

            2'b11: begin  // Simultaneous read and write
                if (empty_reg) begin            // If empty, cannot read
                    wr_ptr_next = wr_ptr_reg;   // Keep write pointer unchanged
                    rd_ptr_next = rd_ptr_reg;   // Keep read pointer unchanged
                end else begin                      // If not empty, perform read and write
                    wr_ptr_next = wr_ptr_reg + 1;   // Increment write pointer
                    rd_ptr_next = rd_ptr_reg + 1;   // Increment read pointer
                end
            end
        endcase
    end
endmodule


