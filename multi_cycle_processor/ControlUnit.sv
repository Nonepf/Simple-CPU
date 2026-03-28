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
    logic branch, pc_update;
    logic [1:0] alu_op;

    ALUDecoder ALUDecoder (
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),

        .alu_control(alu_control)
    );

    InstrDecoder InstrDecoder (
        .op(op),
        .imm_src(imm_src)
    );

    MainFSM MainFSM (
        .op(op),
        .reset(reset),
        .clk(clk),

        .branch(branch), 
        .pc_update(pc_update),
        .reg_write(reg_write), 
        .mem_write(mem_write), 
        .ir_write(ir_write),
        .alu_src_b(alu_src_b), 
        .alu_src_a(alu_src_a), 
        .result_src(result_src),
        .adr_src(adr_src),      
        .alu_op(alu_op)
    );

    assign pc_write = (zero & branch) | pc_update;

endmodule