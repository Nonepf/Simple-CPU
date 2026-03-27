module ControlUnit (
    input logic [2:0]   funct3,
    input logic         funct7,
    input logic [6:0]   op,
    input logic         zero,

    input logic         clk,
    input logic         reset,

    output logic        pc_write, adr_src, mem_write, ir_write,
    output logic        reg_write,
    output logic [1:0]  result_src, alu_src_a, alu_src_b, imm_src,
    output logic [2:0]  alu_control
);


endmodule