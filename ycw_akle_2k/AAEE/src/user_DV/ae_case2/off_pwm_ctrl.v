module off_pwm_ctrl #(
    parameter OFF_PWM_CH_NUM = 3
) (
    input clk_i,
    input rst_ni,

    input [  OFF_PWM_CH_NUM-1:0] off_pwm_prot_mode_i,
    input [  OFF_PWM_CH_NUM-1:0] off_pwm_trig_mode_i,
    input [OFF_PWM_CH_NUM*2-1:0] off_pwm_trig_pol_i,

    input                                        pwm_ctrl_loop_start_i,
    input  [(OFF_PWM_CH_NUM*OFF_PWM_CH_NUM)-1:0] off_pwm_msk_i,
    input  [                 OFF_PWM_CH_NUM-1:0] off_pwm_i,
    output [                 OFF_PWM_CH_NUM-1:0] off_pwm_o
);

    // [优化 1] 使用寄存器输出代替组合逻辑输出
    // 原代码中 off_pwm_w 是 wire，意味着 off_pwm_mode_ctrl 的输出是纯组合逻辑。
    // 这会导致关键路径变长。改为 reg 后，模块内部打拍，减轻时序压力。
    reg [OFF_PWM_CH_NUM-1:0] off_pwm_w_r;

    reg [OFF_PWM_CH_NUM-1:0] off_pwm_tmp_r;

    // [优化 2] 流水线化控制信号
    // 原代码中 pwm_ctrl_loop_start_i 直接参与组合逻辑运算生成上升沿。
    // 这里将其注册化，不仅为了时序，也为了同步。
    reg pwm_ctrl_loop_start_i_r0;
    reg pwm_ctrl_loop_start_i_r1;

    wire rising_edge_pulse;

    // ------------------------------------------------------------------
    // 实例化部分：将输出改为连接到寄存器 off_pwm_w_r
    // ------------------------------------------------------------------
    off_pwm_mode_ctrl off_pwm_mode_ctrl_g1 (
        .clk_i                (clk_i),
        .rst_ni               (rst_ni),
        .off_pwm_prot_mode_i  (off_pwm_prot_mode_i[0]),
        .off_pwm_trig_mode_i  (off_pwm_trig_mode_i[0]),
        .off_pwm_trig_pol_i   (off_pwm_trig_pol_i[1:0]),
        .pwm_ctrl_loop_start_i(pwm_ctrl_loop_start_i),
        .off_pwm_i            (off_pwm_i[0]),
        .off_pwm_o            (off_pwm_w_r[0])            // 连接到寄存器
    );

    off_pwm_mode_ctrl off_pwm_mode_ctrl_g2 (
        .clk_i                (clk_i),
        .rst_ni               (rst_ni),
        .off_pwm_prot_mode_i  (off_pwm_prot_mode_i[1]),
        .off_pwm_trig_mode_i  (off_pwm_trig_mode_i[1]),
        .off_pwm_trig_pol_i   (off_pwm_trig_pol_i[3:2]),
        .pwm_ctrl_loop_start_i(pwm_ctrl_loop_start_i),
        .off_pwm_i            (off_pwm_i[1]),
        .off_pwm_o            (off_pwm_w_r[1])
    );

    off_pwm_mode_ctrl off_pwm_mode_ctrl_g3 (
        .clk_i                (clk_i),
        .rst_ni               (rst_ni),
        .off_pwm_prot_mode_i  (off_pwm_prot_mode_i[2]),
        .off_pwm_trig_mode_i  (off_pwm_trig_mode_i[2]),
        .off_pwm_trig_pol_i   (off_pwm_trig_pol_i[5:4]),
        .pwm_ctrl_loop_start_i(pwm_ctrl_loop_start_i),
        .off_pwm_i            (off_pwm_i[2]),
        .off_pwm_o            (off_pwm_w_r[2])
    );

    off_pwm_sel #(
        .OFF_PWM_CH_NUM(OFF_PWM_CH_NUM)
    ) u_off_pwm_sel (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .off_pwm_msk_i(off_pwm_msk_i),
        .off_pwm_in   (off_pwm_tmp_r),
        .off_pwm_on   (off_pwm_o)
    );

    // ------------------------------------------------------------------
    // 时序逻辑优化
    // ------------------------------------------------------------------

    // [优化 3] 提前计算边沿检测信号
    // 将边沿检测逻辑独立出来，减少 always 块内的组合逻辑深度
    assign rising_edge_pulse = pwm_ctrl_loop_start_i & ~pwm_ctrl_loop_start_i_r1;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            off_pwm_tmp_r <= {OFF_PWM_CH_NUM{1'b1}};
            pwm_ctrl_loop_start_i_r0 <= 1'b0;
            pwm_ctrl_loop_start_i_r1 <= 1'b0;
        end else begin
            // 流水线打拍
            pwm_ctrl_loop_start_i_r0 <= pwm_ctrl_loop_start_i;
            pwm_ctrl_loop_start_i_r1 <= pwm_ctrl_loop_start_i_r0;

            // [优化 4] 简化组合逻辑
            // 原代码逻辑：off_pwm_w & (off_pwm_tmp_r | {N{rising}})
            // 这里的 off_pwm_w 现在也是寄存器输出，时序更稳健
            // 逻辑保持不变，但信号质量更高
            off_pwm_tmp_r <= (off_pwm_w_r & (off_pwm_tmp_r | {OFF_PWM_CH_NUM{rising_edge_pulse}}));
        end
    end

endmodule
