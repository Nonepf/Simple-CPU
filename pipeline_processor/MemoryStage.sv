// ----------------- Memory Stage --------------------
module MemoryStage (
    input logic [31:0]  alu_result_in,
    input logic [31:0]  write_data_in,
    input logic [4:0]   rd_in,
    input logic [31:0]  pc_plus4_in,

    input logic         reg_write_in,
    input logic [1:0]   result_src_in,
    input logic         mem_write_in,

    input logic         clk,
    input logic         reset,

    output logic [31:0] pc_plus4_out,
    output logic [4:0]  rd_out,
    output logic [31:0] read_data_out,
    output logic [31:0] alu_result_out, 

    output logic        reg_write_out,
    output logic [1:0]  result_src_out,

    output logic        reg_write_m,
    output logic [4:0]  rd_m,
    output logic [31:0] alu_result_m
);

    Memory #(.INIT_FILE("data_mem.txt")) DataMemory (
        .a      (alu_result_in),
        .wd     (write_data_in),
        
        .we     (mem_write_in),
        .clk    (clk),
        .reset  (1'b0),

        .rd     (read_data_out)
    );

    always_comb begin
        reg_write_out   = reg_write_in;
        result_src_out  = result_src_in;
        alu_result_out  = alu_result_in;
        rd_out          = rd_in;
        pc_plus4_out    = pc_plus4_in;

        reg_write_m     = reg_write_in;
        rd_m            = rd_in;
        alu_result_m    = alu_result_in;
    end

endmodule