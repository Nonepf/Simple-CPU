module RegisterEn (
    input logic [31:0]  in,
    input logic         clk,
    input logic         reset,
    input logic         en,
    output logic [31:0] out
);
    logic [31:0] register;
    always_ff @(posedge clk) begin
        if (reset) begin
            register <= 1'b0;
        end else if (en) begin
            register <= in;
        end else begin
            register <= register;
        end
    end
    assign out = register;

endmodule