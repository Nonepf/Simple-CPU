// ------------------ Fetch Stage --------------------
module Fetch (
    input logic [31:0]  pc_target,

    input logic         pc_src,

    input logic         clk,
    input logic         reset,
    input logic         stall_f,

    output logic [31:0] pc_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] instr_out
);
    logic [31:0]    pc_next;
    logic           en;
    
    assign en = ~stall_f;

    Mux2To1 PCSelect (
        .a      (pc_plus4_out),
        .b      (pc_target),

        .sel    (pc_src),

        .out    (pc_next)
    );

    RegisterEn PC (
        .in     (pc_next),
        
        .clk    (clk),
        .reset  (reset),
        .en     (en),

        .out    (pc_out)
    );

    Adder32 PCAdder (
        .a      (pc_out),
        .b      (32'd4),
        
        .out    (pc_plus4_out)
    );

    Memory #(.INIT_FILE("instr_mem.txt")) InstrMemory (
        .a      (pc_out),
        .wd     (32'b0),
        .we     (1'b0),
        .clk    (clk),
        .reset  (1'b0),

        .rd     (instr_out)
    );

endmodule