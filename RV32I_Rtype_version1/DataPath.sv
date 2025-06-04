`timescale 1ns / 1ps

// Data Path module for a simplified RV32I CPU
module DataPath (
    input logic        clk,
    input logic        reset,
    input logic [31:0] machineCode,     // 32bit Machine Instruction
    input logic        regFile_wr_en,   // Register File write enable signal
    input logic [2:0] ALUControl,      // ALU Control Signal (Operation Select)

    output logic [31:0] instrMemRAddr   // Instruction memory read address
                                        // Program Counter
);

    wire [31:0] w_ALUResult, w_RegFileRData1, w_RegFileRData2;
    // w_ALUResult : Result from ALU
    // w_RegFileData1 : Read data 1 from register file  
    // w_RegFileData2 : Read data 2 from register file

    // Program Counter Register
    Register U_PC (  
        .clk  (clk),
        .reset(reset),
        .d    (32'b0),  

        .q(instrMemRAddr)   // Output current PC address
    );

    // Register File stores 32 general-purpose 32bit registers
    RegisterFile U_RegisterFile (
        .clk   (clk),
        .wr_en (regFile_wr_en),         // Write enable signal 
        .RAddr1(machineCode[19:15]),    // Source register 1 address (rs1)
        .RAddr2(machineCode[24:20]),    // Source register 2 address (rs2)
        .WAddr (machineCode[11:7]),     // Destination register address (rd)
        .WData (w_ALUResult),           // Data to write to destination register

        .RData1(w_RegFileRData1),       // Read data 1 output
        .RData2(w_RegFileRData2)        // Read data 2 output
    );

    // ALU performs arithmetic and logic operations
    ALU U_ALU (
        .a         (w_RegFileRData1),   // Operand a from register file
        .b         (w_RegFileRData2),   // Operand b from register file
        .ALUControl(ALUControl),        // ALU operation selector

        .result(w_ALUResult)            // Output result
    );
endmodule

// Register File module (32x32)
module RegisterFile (
    input logic        clk,
    input logic        wr_en,
    input logic [ 4:0] RAddr1,  // Read address 1 (rs1)
    input logic [ 4:0] RAddr2,  // Read address 2 (rs2)
    input logic [ 4:0] WAddr,   // Write address (rd)
    input logic [31:0] WData,   // Write data

    output logic [31:0] RData1, // Output read data 1
    output logic [31:0] RData2  // Output read data 2
);
    // Register file memory (32 registers, 32bit wide)
    logic [31:0] RegFile[0:31]; 

    // Initialize some registers for demo
    initial begin     
        RegFile[0] = 32'd0;
        RegFile[1] = 32'd1;
        RegFile[2] = 32'd2;
        RegFile[3] = 32'd3;
        RegFile[4] = 32'd4;
        RegFile[5] = 32'd5;
    end

    // Write operation : synchronous on clock edge
    always_ff @(posedge clk) begin
        if (wr_en) RegFile[WAddr] <= WData; // Write data to WAddr register
    end

    // Read operation (combinational)
    // If read address is 0, always output 0
    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 0;
endmodule


// Single 32bit Register module (Program Counter)
module Register (
    input logic        clk,
    input logic        reset,
    input logic [31:0] d,   // Data input

    output logic [31:0] q   // Data output
);

    // Sequential logic : update q in clock edge or reset
    always_ff @(posedge clk, posedge reset) begin : register  
        if (reset) begin
            q <= 0;     // Reset output to 0
        end else begin
            q <= d;     // Update with input data
        end
    end : register
endmodule

// ALU module for 32bit operations
module ALU (
    input logic [31:0] a,           // Operand a
    input logic [31:0] b,           // Operand b
    input logic [ 2:0] ALUControl,  // ALU control code

    output logic [31:0] result      // Output result
);
    // Define possible ALU operations
    enum logic [2:0] {
        ADD = 3'b000,
        SUB = 3'b001,
        AND = 3'b010,
        OR  = 3'b011
    } alu_op_t;

    // Comnination logic for ALU operation
    always_comb begin
        case (ALUControl)
            ADD:     result = a + b;    // Addition
            SUB:     result = a - b;    // Substraction
            AND:     result = a & b;    // Bitwise AND
            OR:      result = a | b;    // Bitwise OR
            default: result = 32'bx;    // Undefine operation
        endcase
    end
endmodule