module TopModule (
    input logic clk,
    input logic reset
);
    logic [31:0] pc, pc_next, old_pc;
    logic [31:0] read_data, write_data, instr, imm_ext, data, adr;

    logic pc_write, adr_src, mem_write, ir_write, reg_write, zero;
    logic [1:0] result_src;
    logic [2:0] alu_control;
    logic [1:0] alu_src_b, alu_src_a;
    logic [1:0] imm_src;

    logic [31:0] rd1_buf, rd2_buf, a, src_a, src_b;
    logic [31:0] alu_result, alu_out, result;

    // -------------- PC Zone ---------------
    Register PC (
        .in(pc_next),

        .reset(reset),
        .en(pc_write),
        .clk(clk),

        .out(pc)
    );

    Mux2To1 AddrSel (
        .a(pc),
        .b(result),
        .sel(adr_src),

        .out(adr)
    );

    Register OldPC (
        .in(pc),

        .reset(reset),
        .en(ir_write), // Update when a new instruction is read
        .clk(clk),

        .out(old_pc) 
    );

    assign pc_next = result;


    // ----------- Memory Zone ------------
    Memory #(.INIT_FILE("imem.txt")) IDMemory ( // Instr-Data Memory
        .a(adr),
        .wd(write_data),
        
        .clk(clk),
        .we(mem_write),

        .rd(read_data)
    );

    Register IRReg ( // IR Register
        .in(read_data),

        .reset(reset),
        .en(ir_write),
        .clk(clk),

        .out(instr)
    );

    Register DataBuf ( // store data read from memory temporarily
        .in(read_data),

        .reset(reset),
        .en(1'b1),
        .clk(clk),

        .out(data)
    );


    // ---------- Register Zone ------------
    RegisterFile Register (
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .a3(instr[11:7]),
        .wd3(result),

        .reset(reset),
        .clk(clk),
        .we3(reg_write),

        .rd1(rd1_buf),
        .rd2(rd2_buf)
    );

    Register RD1Buf (
        .in(rd1_buf),

        .reset(reset),
        .en(1'b1),
        .clk(clk),

        .out(a)
    );

    Register RD2Buf (
        .in(rd2_buf),

        .reset(reset),
        .en(1'b1),
        .clk(clk),

        .out(write_data)
    );

    Extend Extend (
        .in(instr),
        .sel(imm_src),

        .out(imm_ext)
    );


    // ------------ ALU Zone ------------
    Mux3To1 SrcASel (
        .a(pc),
        .b(old_pc),
        .c(a),
        
        .sel(alu_src_a),

        .out(src_a)
    );

    Mux3To1 SrcBSel (
        .a(write_data),
        .b(imm_ext),
        .c(32'd4),
        
        .sel(alu_src_b),

        .out(src_b)
    );
    
    ALU ALU (
        .a(src_a),
        .b(src_b),

        .ctr(alu_control),
        
        .zero(zero),
        .out(alu_result)
    );

    Register ALUBuf (
        .in(alu_result),

        .reset(reset),
        .en(1'b1),
        .clk(clk),

        .out(alu_out)
    );

    Mux3To1 ResultSel (
        .a(alu_out),
        .b(data),
        .c(alu_result),

        .sel(result_src),

        .out(result)
    );


    // -------------- Control Zone ------------
    ControlUnit ControlUnit (
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[30]),
        .zero(zero),

        .reset(reset),
        .clk(clk),

        .pc_write(pc_write),
        .adr_src(adr_src),
        .mem_write(mem_write),
        .ir_write(ir_write),

        .result_src(result_src),
        .alu_control(alu_control),
        .alu_src_b(alu_src_b),
        .alu_src_a(alu_src_a),
        .imm_src(imm_src),
        .reg_write(reg_write)
    );


endmodule