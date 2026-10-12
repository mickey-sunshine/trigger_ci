module c2k_sig_gen_check (
    input  wire clk_i,         // 时钟信号
    input  wire rst_ni,        // 低电平复位
    input  wire pwm_sel_i,     // tb给的干扰信号, =1时就选用tb的信号
    input  wire pwm_err_i,     // tb给的干扰信号, 模拟pwm错误
    output wire pwm_out_o,     // pwm输出
    output wire interrupt1_o,
    output wire interrupt2_o
);

    localparam PC1_MATCH0 = 16'd200;
    localparam PC1_MATCH1 = 16'd400;
    localparam PC2_MATCH0 = 16'd300;
    localparam PC3_MATCH0 = 16'd500;

    wire pc1_rst;
    wire pc1_zero;
    reg  pwm_pcntout;
    reg  pwm_out_o_d1;
    reg  interrupt1_o_d1;
    reg  interrupt2_o_d1;
    wire f_edge_pwm_out_o;
    pcounter16_clkp_arstn_load #(
        .MATCH0_REF(PC1_MATCH0),
        .MATCH1_REF(PC1_MATCH1)
    ) pc1_pwm_gen (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(pc1_rst),
        .enable_i(1'b1),
        .match0_o(pc1_match0),
        .match1_o(pc1_rst),
        .zero_o(pc1_zero)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_pcntout <= 1'b0;
        end else begin
            if (pc1_match0 == 1) begin
                pwm_pcntout <= 1'b1;
            end else if (pc1_zero == 1) begin
                pwm_pcntout <= 1'b0;
            end else begin
                pwm_pcntout <= pwm_pcntout;
            end
        end
    end
    assign pwm_out_o = pwm_sel_i ? pwm_err_i : pwm_pcntout;
    assign f_edge_pwm_out_o = pwm_out_o_d1 & (~pwm_out_o);
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_out_o_d1 <= 1'b0;
            interrupt1_o_d1 <= 1'b0;
            interrupt2_o_d1 <= 1'b0;
        end else begin
            pwm_out_o_d1 <= pwm_out_o;
            interrupt1_o_d1 <= interrupt1_o;
            interrupt2_o_d1 <= interrupt2_o;
        end
    end

    pcounter16_clkp_arstn_load #(
        .MATCH0_REF(PC2_MATCH0)
    ) pc2_detector_on_time (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i((~pwm_out_o) | interrupt1_o_d1),
        .enable_i(pwm_out_o),
        .match0_o(interrupt1_o),
        .match1_o(),
        .zero_o()
    );

    pcounter16_clkp_arstn_load #(
        .MATCH0_REF(PC3_MATCH0)
    ) pc3_detector_period (
        .clk_i(clk_i),
        .rst_i(rst_ni & (~f_edge_pwm_out_o) & (~interrupt2_o_d1)),
        .up_down_i(1'b0),
        .event_i(),
        .enable_i(1'b1),
        .match0_o(interrupt2_o),
        .match1_o(),
        .zero_o()
    );
endmodule
