// jump is not implemented yet
module ControlUnit (
    input logic [6:0]   op,
    input logic [2:0]   funct3,
    input logic         funct7,

    output logic        branch,
    output logic        jump,
    output logic [1:0]  result_src, // 00 alu, 01 mem, 10 pc_plus4
    output logic        mem_write,
    output logic [2:0]  alu_control,
    output logic        alu_src,
    output logic [1:0]  imm_src,
    output logic        reg_write
);
    logic [1:0] alu_op;
    // ------------- Main Decoder ---------------
    always_comb begin
        // default value
        reg_write   = 1'b0;
        result_src  = 2'b00;
        mem_write   = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        imm_src     = 2'b00;
        alu_src     = 1'b0;
        alu_op      = 2'b00;
        
        case (op)
            7'b0000011: begin // lw
                reg_write   = 1'b1;
                imm_src     = 2'b00;
                alu_src     = 1'b1;
                mem_write   = 1'b0;
                result_src  = 2'b01;
                alu_op      = 2'b00;
                branch      = 1'b0;
                jump        = 1'b0;
            end
            7'b0100011: begin // sw
                reg_write   = 1'b0;
                imm_src     = 2'b01;
                alu_src     = 1'b1;
                mem_write   = 1'b1;
                result_src  = 2'bxx; // an arbitrary choice
                alu_op      = 2'b00;
                branch      = 1'b0;
                jump        = 1'b0;
            end
            7'b0110011: begin // R-type
                reg_write   = 1'b1;
                imm_src     = 2'bxx; // an arbitrary choice
                alu_src     = 1'b0;
                mem_write   = 1'b0;
                result_src  = 2'b00;
                alu_op      = 2'b10;
                branch      = 1'b0;
                jump        = 1'b0;
            end
            7'b1100011: begin // branch
                reg_write   = 1'b0;
                imm_src     = 2'b10;
                alu_src     = 1'b0;
                mem_write   = 1'b0;
                result_src  = 2'bxx; // an arbitrary choice
                alu_op      = 2'b01;
                branch      = 1'b1;
                jump        = 1'b0;
            end
        endcase
    end

    // --------- ALU Decoder ---------
    always_comb begin
        case (alu_op)
            2'b00: alu_control = 3'b010; // lw/sw
            2'b01: alu_control = 3'b110; // beq
            default:
                case (funct3)
                    3'b000: if ({op[5], funct7} == 2'b11) 
                                alu_control = 3'b110; // sub
                            else 
                                alu_control = 3'b010; // add
                    3'b010: alu_control = 3'b111; // slt
                    3'b110: alu_control = 3'b001; // or
                    3'b111: alu_control = 3'b000; // and
                    default: alu_control = 3'b000; // aac
                endcase
        endcase
    end

endmodule