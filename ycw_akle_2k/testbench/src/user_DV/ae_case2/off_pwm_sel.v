module off_pwm_sel #(
    parameter integer OFF_PWM_CH_NUM = 3
) (
    input clk_i,  // 保留时钟（虽然本模块为纯组合逻辑）
    input rst_ni,  // 保留复位
    input [(OFF_PWM_CH_NUM*OFF_PWM_CH_NUM)-1:0] off_pwm_msk_i,
    input [OFF_PWM_CH_NUM-1:0] off_pwm_in,
    output [OFF_PWM_CH_NUM-1:0] off_pwm_on
);

    wire [OFF_PWM_CH_NUM-1:0] off_pwm_o_w;
    genvar i;

    generate
        for (i = 0; i < OFF_PWM_CH_NUM; i = i + 1) begin : gen_output_logic
            assign off_pwm_o_w[i] = |{
                (~off_pwm_in[0] & off_pwm_msk_i[OFF_PWM_CH_NUM*i + 0]),
                (~off_pwm_in[1] & off_pwm_msk_i[OFF_PWM_CH_NUM*i + 1]),
                (~off_pwm_in[2] & off_pwm_msk_i[OFF_PWM_CH_NUM*i + 2])
                // 如果 OFF_PWM_CH_NUM 增加，需在此处继续添加对应项
                };
        end
    endgenerate

    // 最终输出反相
    assign off_pwm_on = ~off_pwm_o_w;

endmodule
