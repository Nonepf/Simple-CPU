// Note: the implementation here is the same as one in ./single_cycle_processor 

module ALU (
    input  logic [31:0] a, b,
    input  logic [2:0]  ctr,

    output logic        zero,
    output logic [31:0] out
);

    always_comb begin
        case (ctr)
            3'b000:  out = a & b;
            3'b001:  out = a | b;
            3'b010:  out = a + b;
            3'b110:  out = a - b;
            3'b111:  out = (a < b) ? 32'h1 : 32'h0;
            default: out = 32'h0;
        endcase
    end

    assign zero = (out == 32'b0);

endmodule