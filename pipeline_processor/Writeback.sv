// ---------------- Writeback Stage ------------------
module Writeback (
    input logic [31:0]  alu_result_in,
    input logic [31:0]  read_data_in,
    input logic [4:0]   rd_in,
    input logic [31:0]  pc_plus4_in,

    input logic         reg_write_in,
    input logic [1:0]   result_src_in,

    input logic         clk,
    input logic         reset,

    output logic        reg_write_out,
    output logic [31:0] result_out,
    output logic [4:0]  rd_out
);
    Mux3To1 Mux (
        .a      (alu_result_in),
        .b      (read_data_in),
        .c      (pc_plus4_in),

        .sel    (result_src_in),

        .out    (result_out)
    );

    always_comb begin
        rd_out          = rd_in;
        reg_write_out   = reg_write_in;
    end

endmodule