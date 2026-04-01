module PipelineTest();
    logic clk, reset;

    TopModule dut (clk, reset);

    // 生成时钟
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; #12;
        reset = 0; 
        #5000;
        $stop;
    end
endmodule