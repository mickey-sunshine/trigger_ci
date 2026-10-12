module tb_C2000_testcase2;

    // C2000_testcase2 Parameters
    parameter PERIOD = 10;
    parameter INPUT_SEL = 1'b0;

    // C2000_testcase2 Inputs
    reg        clk_i = 0;
    reg        rst_ni = 0;
    reg        in1_i = 0;
    reg        in2_i = 0;

    // C2000_testcase2 Outputs
    wire [2:0] event_o;


    initial begin
        forever #(PERIOD / 2) clk_i = ~clk_i;
    end

    initial begin
        #(PERIOD * 2) rst_ni = 1;
    end

    C2000_testcase2 #(
        .INPUT_SEL(INPUT_SEL)
    ) u_C2000_testcase2 (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .in1_i (in1_i),
        .in2_i (in2_i),

        .event_o(event_o[2:0])
    );

    initial begin
        for (int i = 0; i < 30; i++) begin
            in1_i = $random;
            in2_i = $random;
            #(PERIOD);
        end
        $finish;
    end

endmodule
