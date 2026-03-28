// a sublayer of Control Unit
// convert op[6:0] to imm_src[1:0] that decides which bit to decode as immediate number  

module InstrDecoder (
    input logic [6:0]   op,
    output logic [1:0]  imm_src
);
    always_comb begin
        case (op)
            7'b0000011: imm_src = 2'b00; // lw
            7'b0100011: imm_src = 2'b01; // sw
            7'b0110011: imm_src = 2'bxx; // R-type, unknown state
            7'b1100011: imm_src = 2'b10; // beq
            default:    imm_src = 2'bxx; // unkonwn instruction
        endcase
    end
endmodule