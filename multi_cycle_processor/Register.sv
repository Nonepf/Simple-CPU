module Register (
    input logic[31:0] in,
    input logic en, clk, reset,
    output logic[31:0] out
);
    logic [31:0] reg; 
    always_ff @(posedge clk) begin
        if (reset) begin
            reg <= 32'b0;
        end else if (en) begin
            reg <= in;
        end else begin
            reg <= reg;
        end
    end
    assign out = reg;

endmodule