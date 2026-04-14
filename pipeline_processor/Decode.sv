// ----------------- Decode Stage --------------------
module Decode (
    input logic [31:0]  instr_in,
    input logic [31:0]  pc_in,
    input logic [31:0]  pc_plus4_in,

    input logic [31:0]  result_in,
    input logic         reg_write_in,
    input logic [4:0]   rd_in,
    
    input logic         clk,
    input logic         reset,

    output logic [31:0] rd1_out, rd2_out,
    output logic [31:0] pc_out,
    output logic [4:0]  rd_out,
    output logic [31:0] imm_ext_out,
    output logic [31:0] pc_plus4_out,

    output logic        reg_write_out,
    output logic [1:0]  result_src_out, 
    output logic        mem_write_out,
    output logic        jump_out,
    output logic        branch_out,
    output logic [2:0]  alu_control_out,
    output logic        alu_src_out,

    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out
);
    logic [1:0] imm_src;

    RegisterFile RegisterFile (
        .a1         (instr_in[19:15]),
        .a2         (instr_in[24:20]),
        .a3         (rd_in),
        .wd3        (result_in),

        .clk        (clk),
        .reset      (reset),
        .we3        (reg_write_in),

        .rd1        (rd1_out),
        .rd2        (rd2_out)
    );

    Extend Extend (
        .in         (instr_in),
        .sel        (imm_src),
        .out        (imm_ext_out)
    );

    ControlUnit ControlUnit(
        .op         (instr_in[6:0]),
        .funct3     (instr_in[14:12]),
        .funct7     (instr_in[30]),

        .reg_write  (reg_write_out),
        .result_src (result_src_out),
        .mem_write  (mem_write_out),
        .jump       (jump_out), // we need to implement it later
        .branch     (branch_out), // we need to implement it later
        .alu_control(alu_control_out),
        .alu_src    (alu_src_out),
        .imm_src    (imm_src)
    );

    always_comb begin
        pc_out       = pc_in;
        pc_plus4_out = pc_plus4_in;
        rd_out       = instr_in[11:7];

        rs1_out      = instr_in[19:15];
        rs2_out      = instr_in[24:20];
    end

endmodule