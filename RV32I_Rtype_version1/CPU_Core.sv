`timescale 1ns / 1ps


module CPU_Core (
    input logic        clk,
    input logic        reset,
    input logic [31:0] machineCode,

    output logic [31:0] instrMemRAddr
);

    logic w_regFile_wr_en;
    logic [2:0] w_ALUControl;

    ControlUnit U_ControlUnit (  
        .op(machineCode[6:0]),
        .funct3(machineCode[14:12]),
        .funct7(machineCode[31:25]),

        .regFile_wr_en(w_regFile_wr_en),
        .ALUControl(w_ALUControl)
    );

    DataPath U_DataPath (
        .clk(clk),
        .reset(reset),
        .machineCode(machineCode),
        .regFile_wr_en(w_regFile_wr_en),
        .ALUControl(w_ALUControl),

        .instrMemRAddr(instrMemRAddr)
    );
endmodule