// Note: the implementation here is the same as one in ./single_cycle_processor 

module Mux2To1 (
    input  logic [31:0] a, b,
    input  logic        sel,
    output logic [31:0] out
);
    // choose a if sel == 0 else b
    assign out = sel ? b : a; 
endmodule