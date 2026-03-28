// a sublayer of the Control Unit

module ALUDecoder (
    input logic [6:0]   op,
    input logic [1:0]   alu_op,
    input logic [2:0]   funct3,
    input logic         funct7,

    output logic [2:0]  alu_control
);
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