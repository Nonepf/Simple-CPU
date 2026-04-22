module HazardUnit (
    input logic [4:0]   rs1_e, rs2_e,
    input logic [4:0]   rd_m, rd_w,
    input logic         reg_write_m, reg_write_w,

    input logic [4:0]   rs1_d, rs2_d,
    input logic [4:0]   rd_e,
    input logic         result_src_e0,

    input logic         clk,
    input logic         reset,

    output logic [1:0]  forward_ae,
    output logic [1:0]  forward_be,

    output logic        stall_f, stall_d, flush_e
);

    logic lw_stall;

    always_comb begin
        if (rs1_e == rd_m && reg_write_m && rs1_e != 5'b0) begin
            forward_ae = 2'b10; // forward from memory stage
        end else if (rs1_e == rd_w && reg_write_w && rs1_e != 5'b0) begin
            forward_ae = 2'b01; // forward from writeback stage
        end else begin
            forward_ae = 2'b00; // no forwarding
        end
    end

    // the same as the code above
    always_comb begin
        if (rs2_e == rd_m && reg_write_m && rs2_e != 5'b0) begin
            forward_be = 2'b10;
        end else if (rs2_e == rd_w && reg_write_w && rs2_e != 5'b0) begin
            forward_be = 2'b01;
        end else begin
            forward_be = 2'b00;
        end
    end

    assign lw_stall = result_src_e0 && ((rs1_d == rd_e) || (rs2_d == rd_e));
    always_comb begin
        stall_f = lw_stall;
        stall_d = lw_stall;
        flush_e = lw_stall;
    end

endmodule