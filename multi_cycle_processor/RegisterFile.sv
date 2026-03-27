// Note: the implementation here is the same as one in ./single_cycle_processor 

module RegisterFile (
    input logic [4:0]   a1, a2, a3,
    input logic [31:0]  wd3,
    input logic         clk, we3, reset,
    output logic [31:0] rd1, rd2
);
    logic [31:0] registers [31:0];

    assign rd1 = (a1 != 5'b0) ? registers[a1] : 32'b0;
    assign rd2 = (a2 != 5'b0) ? registers[a2] : 32'b0;

    always_ff @(posedge clk) begin
        if (reset) begin
            foreach (registers[i])
                registers[i] <= 32'b0;
        end else if (we3 && (a3 != 5'b0)) begin
            registers[a3] <= wd3;
        end
    end

endmodule