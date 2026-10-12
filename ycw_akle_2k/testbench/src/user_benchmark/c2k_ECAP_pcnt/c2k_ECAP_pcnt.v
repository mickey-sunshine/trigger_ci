module c2k_ECAP_pcnt (
    input        clk_i,     // 输入时钟
    input        rst_ni,    // 输入复位信号
    input        in1_i,     // 输入1
    input        in2_i,     // 输入2
    output [2:0] event_o,   // 输出给HLC的事件
    output [1:0] counter_o  // 避免counter被优化
);

    parameter INPUT_SEL = 1'b0;  // 输入2选1, 0:输入1 1:输入2

    wire signal_in;
    wire rising_edge, falling_edge;
    reg signal_d1, signal_d2;

    reg s0, s1;

    /* boundary input */
    assign signal_in = (INPUT_SEL == 1'b0) ? in1_i : in2_i;
    assign rising_edge = (signal_d2 == 1'b0) && (signal_d1 == 1'b1);
    assign falling_edge = (signal_d2 == 1'b1) && (signal_d1 == 1'b0);
    // 检测状态边沿变化, 采用两级寄存器同步
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_d1 <= 1'b0;
            signal_d2 <= 1'b0;
        end else begin
            signal_d1 <= signal_in;
            signal_d2 <= signal_d1;
        end
    end

    /* FSM */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            s0 = 1'b0;
            s1 = 1'b0;
        end else begin
            s0 = s0 ^ rising_edge;
            s1 = ~(s0 ^ rising_edge);
        end
    end

    /* event */
    assign event_o[0] = falling_edge && s0;
    assign event_o[1] = rising_edge;
    assign event_o[2] = falling_edge && s1;

    /* counter */
    // 内部均使用同步后的信号
    pcounter32_clkp_arstn_load pcnt_High (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(rising_edge),
        .enable_i(signal_d1),
        .match0_o(),
        .match1_o(),
        .zero_o(counter_o[0])
    );
    pcounter32_clkp_arstn_load pcnt_Low (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(falling_edge),
        .enable_i(~signal_d1),
        .match0_o(),
        .match1_o(),
        .zero_o(counter_o[1])
    );

endmodule
