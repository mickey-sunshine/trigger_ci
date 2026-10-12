/* UTF-8 */
module c2k_comb_logic (
    input  [1:0] mode_i,     // 模式控制信号
    input        pwm1a_i,    // 原始PWMA输入
    input        pwm1b_i,    // 原始PWMB输入
    output       pwm1a_m_o,  // 处理后的PWMA输出
    output       pwm1b_m_o   // 处理后的PWMB输出
);
    //00:正常, 01:高电平有效, 10:低电平有效, 11:保留
    localparam M0 = 2'b00;
    localparam M1 = 2'b01;
    localparam M2 = 2'b10;
    localparam M3 = 2'b11;

    assign pwm1a_m_o = (pwm1a_i == pwm1b_i) ? (mode_i == M0) ? pwm1a_i:
                                              (mode_i == M1) ? 1'b1:1'b0
                                              :pwm1a_i;
    assign pwm1b_m_o = (pwm1a_i == pwm1b_i) ? (mode_i == M0) ? pwm1b_i:
                                              (mode_i == M1) ? 1'b1:1'b0
                                              :pwm1b_i;

endmodule

