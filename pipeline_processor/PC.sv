module PC (
    input logic [31:0]  in,
    input logic         clk,
    input logic         reset,
    output logic [31:0] out
);
    logic [31:0] pc;
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= 1'b0;
        end else begin
            pc <= in;
        end
    end
    assign out = pc;

endmodule