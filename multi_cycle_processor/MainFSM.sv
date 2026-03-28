// a sublayer of Control Unit

module MainFSM (
    input logic [6:0]   op,
    input logic         reset,
    input logic         clk,

    output logic        branch, pc_update,
    output logic        reg_write, mem_write, ir_write,
    output logic [1:0]  alu_src_b, alu_src_a, result_src,
    output logic        adr_src,       
    output logic [1:0]  alu_op 
);
    // state
    parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011;
    parameter S4 = 4'b0100, S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111;
    parameter S8 = 4'b1000, S9 = 4'b1001, S10 = 4'b1010;
    // S8, S9 remain to be defined

    logic [3:0] state, next_state;

    // combinational logic of the FSM
    always_comb begin
        
        case (state)
            S0: next_state = S1;
            S1: begin
                case (op)
                    7'b0000011: next_state = S2;    // MemAdr (lw)
                    7'b0100011: next_state = S2;    // MemAdr (sw)
                    7'b0110011: next_state = S6;    // ExecuteR (R-type)
                    7'b1100011: next_state = S10;   // BEQ (beq)
                endcase
            end
            S2: begin
                case (op)
                    7'b0000011: next_state = S3;    // MemRead (lw)
                    7'b0100011: next_state = S5;    // MemWrite (sw)
                endcase
            end
            S3: next_state = S4;                    // MemWB
            S4: next_state = S0;
            S5: next_state = S0;
            S6: next_state = S7;                    // ALUWB
            S7: next_state = S0;
            S10: next_state = S0;
        endcase
    end

    // update the state
    always_ff @(posedge clk) begin
        if (reset)
            state <= S0;
        else 
            state <= next_state;
    end

    // decide values depending on current state
    always_comb begin
        adr_src    = 1'b0;
        ir_write   = 1'b0;
        pc_update  = 1'b0;
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        alu_src_a  = 2'b00;
        alu_src_b  = 2'b00;
        result_src = 2'b00;
        alu_op     = 2'b00;

        case (state) 
            S0: begin
                adr_src = 1'b0; ir_write = 1'b1; 
                alu_src_a = 2'b00; alu_src_b = 2'b10;
                result_src = 2'b10; pc_update = 1'b1;
                alu_op = 2'b00;
            end
            S1: begin
                alu_src_a = 2'b01; alu_src_b = 2'b01;
            end
            S2: begin
                alu_src_a = 2'b10; alu_src_b = 2'b01;
            end
            S3: begin
                result_src = 2'b00; adr_src = 1'b1;
            end
            S4: begin
                result_src = 2'b01; reg_write = 1'b1;
            end
            S5: begin
                result_src = 2'b00; adr_src =  1'b1;
                mem_write = 1'b1;
            end
            S6: begin
                alu_src_a = 2'b10; alu_src_b = 2'b00;
                alu_op = 2'b10;
            end
            S7: begin
                result_src = 2'b00; reg_write = 1'b1;
            end
            S10: begin
                alu_src_a = 2'b10; alu_src_b = 2'b00;
                result_src = 2'b00; branch = 1'b1;
                alu_op = 2'b01;
            end
        endcase
    end         

endmodule