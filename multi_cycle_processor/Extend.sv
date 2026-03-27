// Note: the implementation here is the same as one in ./single_cycle_processor 

module Extend (
    input logic [31:0]  in,
    input logic [1:0]   sel,

    output logic [31:0] out
);
    always_comb begin
        case (sel)
            2'b00: out = {{20{in[31]}}, in[31:20]};                     // I-Type
            2'b01: out = {{20{in[31]}}, in[31:25], in[11:7]};           // S-Type
            2'b10: out = {{21{in[31]}}, in[7], in[30:25], in[11:8]};    // B-Type
        endcase
    end

endmodule