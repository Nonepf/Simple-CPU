module Register (
    input logic [31:0]  in,
    input logic         clk,
    input logic         reset,
    output logic [31:0] out
);
    logic [31:0] register;
    always_ff @(posedge clk) begin
        if (reset) begin
            register <= 1'b0;
        end else begin
            register <= in;
        end
    end
    assign out = register;

endmodule