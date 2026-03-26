module Test();
    logic clk, reset;
    //logic [31:0] write_data, data_adr;
    //logic mem_write;

    TopModule dut (clk, reset);

    // 生成时钟
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; #12;
        reset = 0; 
        #200;
        $stop;
    end
endmodule