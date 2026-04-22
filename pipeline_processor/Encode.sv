// ----------------- Execute Stage -------------------
module Encode (
    input logic [31:0]  rd1_in, rd2_in,
    input logic [31:0]  pc_in,
    input logic [4:0]   rd_in,
    input logic [31:0]  imm_ext_in,
    input logic [31:0]  pc_plus4_in,

    input logic         reg_write_in,
    input logic [1:0]   result_src_in, 
    input logic         mem_write_in,
    input logic         jump_in,
    input logic         branch_in,
    input logic [2:0]   alu_control_in,
    input logic         alu_src_in,

    input logic [4:0]   rs1_in,
    input logic [4:0]   rs2_in,
    input logic [31:0]  result_in,
    input logic [31:0]  alu_result_in,
    
    input logic [1:0]   forward_ae,
    input logic [1:0]   forward_be,

    input logic         clk,
    input logic         reset,

    output logic        pc_src_out,
    output logic [31:0] pc_target_out,

    output logic        reg_write_out,
    output logic [1:0]  result_src_out,
    output logic        mem_write_out,

    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0]  rd_out,
    output logic [31:0] pc_plus4_out,

    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,

    output logic        result_src_out0,
);
    logic [31:0]    src_a, src_b, mid_b;
    logic           zero;

    Adder32 Adder (
        .a      (pc_in),
        .b      (imm_ext_in),
        .out    (pc_target_out)
    );

    Mux3To1 MuxSrcA (
        .a      (rd1_in),
        .b      (result_in),
        .c      (alu_result_in),
        .sel    (forward_ae),
        .out    (src_a)
    );

    Mux3To1 MuxSrcB (
        .a      (rd2_in),
        .b      (result_in),
        .c      (alu_result_in),
        .sel    (forward_be),
        .out    (mid_b) // connect MuxSrcB and Mux
    );

    Mux2To1 Mux (
        .a      (mid_b),
        .b      (imm_ext_in),
        .sel    (alu_src_in),
        .out    (src_b)
    );

    ALU ALU (
        .a      (src_a),
        .b      (src_b),
        .ctr    (alu_control_in),
        .zero   (zero),
        .out    (alu_result_out)
    );

    assign pc_src_out = (zero & branch_in) | jump_in;

    always_comb begin
        reg_write_out   = reg_write_in;
        result_src_out  = result_src_in;
        mem_write_out   = mem_write_in;
        pc_plus4_out    = pc_plus4_in;
        rd_out          = rd_in;
        write_data_out  = rd2_in;

        rs1_out         = rs1_in;
        rs2_out         = rs2_in;

        result_src_out0 = result_src_in[0];
    end

endmodule