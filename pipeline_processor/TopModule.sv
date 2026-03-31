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

    // other signals needed
    logic zero;
    logic pc_src;

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

    // ------------------ Fetch Stage --------------------



    // ----------------- Decode Stage --------------------

    // ----------------- Execute Stage -------------------

    // ----------------- Memory Stage --------------------

    // ---------------- Writeback Stage ------------------

endmodule