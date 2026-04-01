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
        // logic zero;
        // logic [31:0] pc_target;
    } e2m_t;

    // M -> W 传递的信号
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

    
    /*
    always_comb begin
        pipe_f2d_next.instr     = instr_rd;
        pipe_f2d_next.pc        = pc;
        pipe_f2d_next.pc_plus4  = pc_plus4;
    end
    */






endmodule


// ------------------ Fetch Stage --------------------
module Fetch (
    input logic [31:0] pc_target;

    input logic pc_src;

    input logic clk;
    input logic reset;

    output logic [31:0] pc_out;
    output logic [31:0] pc_plus4_out;
    output logic [31:0] instr_out;
);
    output logic [31:0] pc_next;
    Mux2To1 PCSelect (
        .a      (pc_plus4),
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
        .a      (pc),
        .b      (32'd4),
        
        .out    (pc_plus4_out)
    );

    Memory #(.INIT_FILE("instr_mem.txt")) InstrMemory (
        .a      (pc),
        .wd     (32'b0),
        .we     (1'b0),
        .clk    (clk),
        .reset  (1'b0),

        .rd     (instr_out)
    );

endmodule


// ----------------- Decode Stage --------------------
module Decode (
    input logic [31:0]  instr_in;
    input logic [31:0]  pc_in;
    input logic [31:0]  pc_plus_in;

    input logic         reg_write_in;
    input logic [4:0]   rd_in;
    input logic [31:0]  result_in; 
    
    input logic         clk;
    input logic         reset;

    output logic [31:0] rd1_out, rd2_out;
    output logic [31:0] pc_out;
    output logic [4:0]  rd_out;
    output logic [31:0] imm_ext_out;
    output logic [31:0] pc_plus_out;

    output logic        reg_write_out; 
    output logic [1:0]  result_src_out; 
    output logic        mem_write_out; 
    output logic        jump_out; 
    output logic        branch_out;
    output logic [2:0]  alu_control_out;
    output logic        alu_src_out; 
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
        .zero       (1'b0), // we don't need this bit now

        .pc_src     (), // we need to delete it later 

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
    assign pc_plus4_out = pc_plus_4_in;

endmodule


// ----------------- Execute Stage -------------------
module Encode (
    input logic [31:0]  rd1_in, rd2_in;
    input logic [31:0]  pc_in;
    input logic [31:0]  rd_in;
    input logic [31:0]  imm_ext_in;
    input logic [31:0]  pc_plus4_in;

    output logic        reg_write_in; 
    output logic [1:0]  result_src_in; 
    output logic        mem_write_in; 
    output logic        jump_in; 
    output logic        branch_in;
    output logic [2:0]  alu_control_in;
    output logic        alu_src_in; 

    input logic         clk;
    input logic         reset;

    output logic [31:0] pc_src_out;
    output logic [31:0] pc_target_out;

    output logic [31:0] alu_result_out;
    output logic [31:0] write_data_out;
    output logic [4:0]  rd_out;
    output logic [31:0] pc_plus4_out;
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
        pc_plus4_in     = pc_plus4_out;
        rd_out          = rd_in;
    end

endmodule


// ----------------- Memory Stage --------------------
module Memory (
    input logic [31:0]  alu_result_in;
    input logic [31:0]  write_data_in;
    input logic [4:0]   rd_in;
    input logic [31:0]  pc_plus4_in;

    input logic         reg_write_in;
    input logic [1:0]   result_src_in;
    input logic         mem_write_in;

    input logic         clk;
    input logic         reset;

    output logic [31:0] pc_plus4_out;
    output logic [4:0]  rd_out;
    output logic [31:0] read_data_out;
    output logic [31:0] alu_result_out; 

    output logic        reg_write_out;
    output logic [1:0]  result_src_out;
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
    input logic [31:0]  alu_result_in;
    input logic [31:0]  read_data_in;
    input logic [4:0]   rd_in;
    input logic [31:0]  pc_plus4_in;

    input logic         reg_write_in;
    input logic [1:0]   result_src_in;

    input logic         clk;
    input logic         reset;

    output logic        reg_write_out;
    output logic [31:0] result_out;
    output logic [4:0]  rd_out;
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