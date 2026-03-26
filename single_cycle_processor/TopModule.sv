module TopModule (
    input logic clk, reset
);
/* Extern Unit
 *
 */
    // pc_add4 means pc + 4, pc_cal comes from branchs. 
    logic [31:0] pc_next, pc_add4, pc_cal;
    logic [31:0] pc;

    logic [31:0] instr;
    
    logic [31:0] src_a, src_b, src_b_pre;

    logic [31:0] imm_ext, result, read_data;

    logic zero;
    logic [31:0] alu_result;

    logic pc_src, result_src, mem_write, alu_src, reg_write;
    logic [2:0] alu_control;
    logic [1:0] imm_src;

/* PC Unit
 *
 */
    PC pc_reg (
        .in     (pc_next),
        .clk    (clk),
        .reset  (reset),
        .out    (pc)
    );

    Adder32 pc_plus (
        .a      (pc),
        .b      (32'd4),
        .out    (pc_add4)
    );

    Mux2To1 pc_sel (
        .a      (pc_add4),
        .b      (pc_cal),
        .sel    (pc_src),
        .out    (pc_next)
    );

/* Register
 *
 */
    Memory #(.INIT_FILE("imem.txt")) instruction_memory (
        .a      (pc),
        .wd     (32'b0),
        .we     (1'b0),
        .clk    (clk), // is it necessary?
        .reset  (1'b0),

        .rd     (instr)
    );

    RegisterFile register (
        .a1     (instr[19:15]),
        .a2     (instr[24:20]),
        .a3     (instr[11:7]),
        .wd3    (result), // result from the whole computing process

        .clk    (clk),
        .reset  (reset),
        .we3    (reg_write),

        .rd1    (src_a),
        .rd2    (src_b_pre)
    );

    Mux2To1 srcb_sel (
        .a      (src_b_pre),
        .b      (imm_ext),
        .sel    (alu_src),

        .out    (src_b)
    );

/* Immediate Number Extension Unit
 *
 */
    Extend extend (
        .in     (instr[31:0]),
        .sel    (imm_src),
        .out    (imm_ext)
    );

    Adder32 pc_target (
        .a      (imm_ext),
        .b      (pc),
        .out    (pc_cal)
    );

/* ALU Unit
 *
 */
    ALU alu (
        .a      (src_a),
        .b      (src_b),
        .ctr    (alu_control),

        .zero   (zero),
        .out    (alu_result)
    );

    Memory #(.INIT_FILE("")) data_memory (
        .a      (alu_result),
        .wd     (src_b_pre), // the same as "write_data"

        .clk    (clk),
        .reset  (reset),
        .we     (mem_write),

        .rd     (read_data)
    );

    Mux2To1 result_sel (
        .a      (alu_result),
        .b      (read_data),
        .sel    (result_src),
        
        .out    (result)
    );

/* Control Unit
 *
 */
    ControlUnit control_unit (
        .op     (instr[6:0]),
        .funct3 (instr[14:12]),
        .funct7 (instr[30]),
        .zero   (zero),

        .pc_src  (pc_src),
        .result_src (result_src),
        .mem_write  (mem_write),
        .alu_control (alu_control),
        .alu_src    (alu_src),
        .imm_src    (imm_src),
        .reg_write  (reg_write)
    );

endmodule