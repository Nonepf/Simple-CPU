module Memory #(
    parameter INIT_FILE = ""
) (
    input logic [31:0]  a, wd,
    input logic         clk, we, reset,
    output logic [31:0] rd
);
    logic [31:0] memory [31:0];
    always_comb begin
        rd = memory[a[31:2]];
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            foreach (memory[i])
                memory[i] <= 32'b0;
        end else if (we) begin
            memory[a[31:2]] <= wd;
        end
    end

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, memory);
        end
    end

endmodule