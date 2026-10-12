/* UTF-8 */
module c2k_single_PWM_pcnt (
    input       clk_i,       // 输入时钟 (假设是100Mhz)
    input       rst_ni,      // 输入复位信号
    input       trig_a_i,    // 输入触发信号a
    input       trig_b_i,    // 输入触发信号b
    input       trig_sel_i,  // 触发信号选择
    output wire pwm_o        // 单次PWM输出 (脉宽为200ns-800ns, 不含ccb则固定200ns)
);

    // 20*10ns=200ns
    localparam CNT_MAX_VAL = 16'd20;
    wire signal_in;
    reg signal_in_d1, signal_in_d2;
    wire r_edge;
    wire pcnt0_match0;
    reg  pcnt0_match0_d1;
    reg  s0;
    wire e0, e1;

    // 输入信号选择
    assign signal_in = (trig_sel_i == 0) ? trig_a_i : trig_b_i;

    // 输入信号打两拍
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_in_d1 <= 1'b0;
            signal_in_d2 <= 1'b0;
        end else begin
            signal_in_d1 <= signal_in;
            signal_in_d2 <= signal_in_d1;
        end
    end

    // 获取输入信号上升沿
    assign r_edge = signal_in_d1 & (~signal_in_d2);

    // FSM
    assign e0 = r_edge;
    assign e1 = pcnt0_match0;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            s0 <= 1'b0;
        end else begin
            s0 <= (~e0 & (~e1) & s0) | e0;
        end
    end

    // PCNT
    pcounter16_clkp_arstn_load #(
        .MATCH0_REF(CNT_MAX_VAL)
    ) pcnt0 (
        .clk_i(clk_i),
        .rst_i((~pcnt0_match0_d1) & (rst_ni)),
        // .rst_i((rst_ni)),
        .up_down_i(1'b0),
        .event_i(),
        .enable_i(s0),
        .match0_o(pcnt0_match0),
        .match1_o(),
        .zero_o()
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pcnt0_match0_d1 <= 1'b0;
        end else begin
            pcnt0_match0_d1 <= pcnt0_match0;
        end
    end

    // 输出信号
    assign pwm_o = (~pcnt0_match0) & s0;

endmodule
