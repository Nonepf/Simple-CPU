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

        // data hazard with forwarding
        logic [4:0] rs1;
        logic [4:0] rs2; 
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
  
    // General Definition
    logic [31:0]    pc_target;
    logic           pc_src;
    logic [4:0]     rd;
    logic [31:0]    result;
    logic           reg_write;

    // General Definition for Data Hazards with Forwarding
    logic [31:0]    alu_result_m;
    logic [4:0]     rd_m;
    logic [4:0]     rd_w;
    logic           reg_write_m;
    logic           reg_write_w;
    logic [1:0]     forward_ae, forward_be;
    logic [4:0]     rs1_e, rs2_e;

    logic           stall_f, stall_d, flush_e;
    logic [4:0]     rs1_d, rs2_d;
    logic [4:0]     rd_e;
    logic           result_src_e0;

    assign reg_write_w  = reg_write;
    assign rd_w         = rd;

    // Hazard Unit
    HazardUnit Hazard (
        .rs1_e          (rs1_e),
        .rs2_e          (rs2_e),
        .rd_m           (rd_m),
        .rd_w           (rd_w),
        .reg_write_m    (reg_write_m),
        .reg_write_w    (reg_write_w),

        .rs1_d          (rs1_d),
        .rs2_d          (rs2_d),
        .rd_e           (rd_e),
        .result_src_e0  (result_src_e0),

        .clk            (clk),
        .reset          (reset),

        .forward_ae     (forward_ae),
        .forward_be     (forward_be),

        .stall_f        (stall_f),
        .stall_d        (stall_d),
        .flush_e        (flush_e)
    );

    // Fetch
    Fetch Fetch (
        .pc_target      (pc_target),
        .pc_src         (pc_src),

        .stall_f        (stall_f),

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
        .alu_src_out        (pipe_d2e_next.alu_src),

        .rs1_out            (pipe_d2e_next.rs1),
        .rs2_out            (pipe_d2e_next.rs2),

        .rs1_out_2          (rs1_d),
        .rs2_out_2          (rs2_d)
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

        .rs1_in          (pipe_d2e.rs1),
        .rs2_in          (pipe_d2e.rs2),
        .result_in       (result),
        .alu_result_in   (alu_result_m),
        .forward_ae      (forward_ae),
        .forward_be      (forward_be),

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
        .pc_plus4_out    (pipe_e2m_next.pc_plus4),

        .rs1_out         (rs1_e),
        .rs2_out         (rs2_e),

        .result_src_out0 (result_src_e0)
    );

    // Memory
    MemoryStage MemoryStage (
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
        .result_src_out  (pipe_m2w_next.result_src),
        
        .reg_write_m     (reg_write_m), // the same as reg_write_out
        .rd_m            (rd_m),
        .alu_result_m    (alu_result_m)
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
    
    // initialize
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pipe_f2d <= '0;
            pipe_d2e <= '0;
            pipe_e2m <= '0;
            pipe_m2w <= '0;
        end else begin
            if (stall_d) begin
                pipe_f2d <= pipe_f2d_next;
            end else begin
                pipe_f2d <= pipe_f2d;
            end

            if (flush_e) begin
                pipe_d2e <= pipe_d2e_next;
            end else begin
                pipe_d2e <= '0;
            end
            
            pipe_e2m <= pipe_e2m_next;
            pipe_m2w <= pipe_m2w_next;
        end
    end



endmodule
