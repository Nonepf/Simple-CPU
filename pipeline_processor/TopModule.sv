module TopModule (
    input logic clk, reset
);
    /* Pipeline CPU
     * Five stages: Fetch, Decode, Execute, Memory, Writeback
     */

    // --------------- Initilalize Zone -----------
    // Pipeline Register Definition 
    // F -> D
    typedef struct packed {
        logic [31:0] pc;
        logic [31:0] pc_plus4;
        logic [31:0] instr;
    } f2d_t;

    // D -> E
    typedef struct packed {
        // control signal
        logic reg_write;
        logic mem_write;
        logic jump;
        logic branch;
        logic alu_src;
        logic [1:0] result_src;
        logic [2:0] alu_control;
        // logic [1:0] imm_src;
        
        // data path
        logic [31:0] imm_ext;
        logic [31:0] pc;
        logic [31:0] pc_plus4;
        logic [4:0]  rd;
        logic [31:0] rd1;
        logic [31:0] rd2;
    } d2e_t;

    // E -> M
    typedef struct packed {
        // control signal
        logic reg_write;
        logic mem_write;
        logic [1:0] result_src;

        // data path
        logic [4:0]  rd;
        logic [31:0] alu_result;
        logic [31:0] write_data;
        logic [31:0] pc_plus4;
    } e2m_t;

    // M -> W
    typedef struct packed {
        // control signal
        logic reg_write;
        logic [1:0] result_src;

        // data path
        logic [4:0]  rd;
        logic [31:0] read_data;
        logic [31:0] alu_result;
        logic [31:0] pc_plus4;
    } m2w_t;

    // define
    f2d_t pipe_f2d, pipe_f2d_next;
    d2e_t pipe_d2e, pipe_d2e_next;
    e2m_t pipe_e2m, pipe_e2m_next;
    m2w_t pipe_m2w, pipe_m2w_next;

    // initialize
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pipe_f2d <= '0;
            pipe_d2e <= '0;
            pipe_e2m <= '0;
            pipe_m2w <= '0;
        end else begin
            pipe_f2d <= pipe_f2d_next;
            pipe_d2e <= pipe_d2e_next;
            pipe_e2m <= pipe_e2m_next;
            pipe_m2w <= pipe_m2w_next;
        end
    end
  
    // General Definition
    logic [31:0]    pc_target;
    logic           pc_src;
    logic [4:0]     rd;
    logic [31:0]    result;
    logic           reg_write;

    // Fetch
    Fetch Fetch (
        .pc_target      (pc_target),
        .pc_src         (pc_src),

        .clk            (clk),
        .reset          (reset),

        .pc_out         (pipe_f2d_next.pc),
        .pc_plus4_out   (pipe_f2d_next.pc_plus4),
        .instr_out      (pipe_f2d_next.instr)
    );

    // Decode
    Decode Decode (
        .instr_in           (pipe_f2d.instr),
        .pc_in              (pipe_f2d.pc),
        .pc_plus4_in        (pipe_f2d.pc_plus4),

        .result_in          (result),
        .reg_write_in       (reg_write),
        .rd_in              (rd),
        
        .clk                (clk),
        .reset              (reset),
        
        .rd1_out            (pipe_d2e_next.rd1),
        .rd2_out            (pipe_d2e_next.rd2),
        .pc_out             (pipe_d2e_next.pc),
        .rd_out             (pipe_d2e_next.rd),
        .imm_ext_out        (pipe_d2e_next.imm_ext),
        .pc_plus4_out       (pipe_d2e_next.pc_plus4),
        
        .reg_write_out      (pipe_d2e_next.reg_write),
        .result_src_out     (pipe_d2e_next.result_src),
        .mem_write_out      (pipe_d2e_next.mem_write),
        .jump_out           (pipe_d2e_next.jump),
        .branch_out         (pipe_d2e_next.branch),
        .alu_control_out    (pipe_d2e_next.alu_control),
        .alu_src_out        (pipe_d2e_next.alu_src)
    );

    // Encode
    Encode Encode (
        .rd1_in          (pipe_d2e.rd1),
        .rd2_in          (pipe_d2e.rd2),
        .pc_in           (pipe_d2e.pc),
        .rd_in           (pipe_d2e.rd),
        .imm_ext_in      (pipe_d2e.imm_ext),
        .pc_plus4_in     (pipe_d2e.pc_plus4),

        .reg_write_in    (pipe_d2e.reg_write),
        .result_src_in   (pipe_d2e.result_src),
        .mem_write_in    (pipe_d2e.mem_write),
        .jump_in         (pipe_d2e.jump),
        .branch_in       (pipe_d2e.branch),
        .alu_control_in  (pipe_d2e.alu_control),
        .alu_src_in      (pipe_d2e.alu_src),

        .clk             (clk),
        .reset           (reset),

        .pc_src_out      (pc_src),
        .pc_target_out   (pc_target),

        .reg_write_out   (pipe_e2m_next.reg_write),
        .result_src_out  (pipe_e2m_next.result_src),
        .mem_write_out   (pipe_e2m_next.mem_write),

        .alu_result_out  (pipe_e2m_next.alu_result),
        .write_data_out  (pipe_e2m_next.write_data),
        .rd_out          (pipe_e2m_next.rd),
        .pc_plus4_out    (pipe_e2m_next.pc_plus4)
    );

    // Memory
    Memory Memory (
        .alu_result_in   (pipe_e2m.alu_result),
        .write_data_in   (pipe_e2m.write_data),
        .rd_in           (pipe_e2m.rd),
        .pc_plus4_in     (pipe_e2m.pc_plus4),

        .reg_write_in    (pipe_e2m.reg_write),
        .result_src_in   (pipe_e2m.result_src),
        .mem_write_in    (pipe_e2m.mem_write),

        .clk             (clk),
        .reset           (reset),

        .pc_plus4_out    (pipe_m2w_next.pc_plus4),
        .rd_out          (pipe_m2w_next.rd),
        .read_data_out   (pipe_m2w_next.read_data),
        .alu_result_out  (pipe_m2w_next.alu_result),

        .reg_write_out   (pipe_m2w_next.reg_write),
        .result_src_out  (pipe_m2w_next.result_src)
    );

    // Writeback
    Writeback Writeback (
        .alu_result_in   (pipe_m2w.alu_result),
        .read_data_in    (pipe_m2w.read_data),
        .rd_in           (pipe_m2w.rd),
        .pc_plus4_in     (pipe_m2w.pc_plus4),

        .reg_write_in    (pipe_m2w.reg_write),
        .result_src_in   (pipe_m2w.result_src),

        .clk             (clk),
        .reset           (reset),

        .reg_write_out   (reg_write),
        .result_out      (result),
        .rd_out          (rd)
    );



endmodule


// ------------------ Fetch Stage --------------------
module Fetch (
    input logic [31:0]  pc_target,

    input logic         pc_src,

    input logic         clk,
    input logic         reset,

    output logic [31:0] pc_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] instr_out
);
    logic [31:0] pc_next;
    Mux2To1 PCSelect (
        .a      (pc_plus4_out),
        .b      (pc_target),

        .sel    (pc_src),

        .out    (pc_next)
    );

    Register PC (
        .in     (pc_next),
        
        .clk    (clk),
        .reset  (reset),

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
    output logic        alu_src_out
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
        .in         (instr_in[31:7]),
        .sel        (imm_src),
        .out        (imm_ext_out)
    );

    /*
module ControlUnit (
    input logic [6:0]   op,
    input logic [2:0]   funct3,
    input logic         funct7,
    input logic         zero,

    output logic        pc_src,     // 0 origin, 1 branch
    output logic        result_src, // 0 alu, 1 mem
    output logic        mem_write,
    output logic [2:0]  alu_control,
    output logic        alu_src,
    output logic [1:0]  imm_src,
    output logic        reg_write
);*/

    // this module remains to be modified
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

    assign pc_out       = pc_in;
    assign pc_plus4_out = pc_plus4_in;

endmodule


// ----------------- Execute Stage -------------------
module Encode (
    input logic [31:0]  rd1_in, rd2_in,
    input logic [31:0]  pc_in,
    input logic [31:0]  rd_in,
    input logic [31:0]  imm_ext_in,
    input logic [31:0]  pc_plus4_in,

    output logic        reg_write_in,
    output logic [1:0]  result_src_in, 
    output logic        mem_write_in,
    output logic        jump_in,
    output logic        branch_in,
    output logic [2:0]  alu_control_in,
    output logic        alu_src_in,

    input logic         clk,
    input logic         reset,

    output logic [31:0] pc_src_out,
    output logic [31:0] pc_target_out,

    output logic        reg_write_out,
    output logic [1:0]  result_src_out,
    output logic        mem_write_out,

    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0]  rd_out,
    output logic [31:0] pc_plus4_out
);
    logic [31:0]    src_a, src_b;
    logic           zero;

    assign src_a    = rd1_in;

    Adder32 Adder (
        .a      (pc_in),
        .b      (rd_in),
        .out    (pc_target_out)
    );

    Mux2To1 Mux (
        .a      (rd2_in),
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
        pc_plus4_out     = pc_plus4_in;
        rd_out          = rd_in;
    end

endmodule


// ----------------- Memory Stage --------------------
module Memory (
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
    output logic [1:0]  result_src_out
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
    end

endmodule


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