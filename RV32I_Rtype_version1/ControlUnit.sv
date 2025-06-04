`timescale 1ns / 1ps

// Control Unit module
// Generates control signals for the data path based on the opcode & function fields
module ControlUnit (  
    input logic [6:0] op,       // Opcode field from instruction memory
    input logic [2:0] funct3,   // funct3 field
    input logic [6:0] funct7,   // funct7 field

    output logic       regFile_wr_en,   // Output control : Register File write enable
    output logic [2:0] ALUControl       // Output control : ALU operation selector
);

    logic controls; // Internal control signal for regfile write enable

    assign regFile_wr_en = controls;

    // Determine register file write enable based on instruction opcode
    always_comb begin
        case (op)
            7'b0110011: controls = 1'b1;  // R-Type (register-register instructions)
            7'b0000011: controls = 1'b0;  // IL-Type (load instructions)
            7'b0010011: controls = 1'b0;  // I-Type (immediate instructions)
            7'b0100011: controls = 1'b0;  // S-Type (store instructions)
            7'b1100011: controls = 1'b0;  // B-Type (branch instructions)
            7'b0110111: controls = 1'b0;  // LUI-Type (load upper immediate)
            7'b0010111: controls = 1'b0;  // AUIPC-Type (add upper immediate to PC)
            7'b1101111: controls = 1'b0;  // J-Type (jump instructions)
            7'b1100111: controls = 1'b0;  // JI-Type (jump & link register)
            default: controls = 1'b0;  // JI-Type (disble register file write)
        endcase
    end

    // Determine ALU operation based on funct7 & funct3 fields
    always_comb begin
        // Create 4bit selector
        case ({funct7[5], funct3})  
            4'b0000: ALUControl = 3'b000; // ADD
            4'b1000: ALUControl = 3'b001; // SUB
            4'b0110: ALUControl = 3'b011; // OR   
            4'b0111: ALUControl = 3'b010; // AND
            default: ALUControl = 3'bx;   // Undefined operation
        endcase
    end

endmodule