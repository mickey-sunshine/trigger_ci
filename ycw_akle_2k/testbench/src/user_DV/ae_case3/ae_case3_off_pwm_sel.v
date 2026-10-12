//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/23 8:52:16
// Design Name: 
// Module Name: off_pwm_grp_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ae_case3_off_pwm_sel #(
    parameter integer OFF_PWM_CH_NUM = 3
) (
    input clk_i,
    input rst_ni,

    // A flattened OFF_PWM_CH_NUM x OFF_PWM_CH_NUM mask vector.
    // Layout: for each output channel i, bits [OFF_PWM_CH_NUM*i +: OFF_PWM_CH_NUM]
    // correspond to input channels j = 0..OFF_PWM_CH_NUM-1.
    input [(OFF_PWM_CH_NUM*OFF_PWM_CH_NUM)-1:0] off_pwm_msk_i,

    input  [OFF_PWM_CH_NUM-1:0] off_pwm_in,
    output [OFF_PWM_CH_NUM-1:0] off_pwm_on
);
    wire [OFF_PWM_CH_NUM-1:0] off_pwm_o_w;

    genvar i, j;

    // For each output channel i, build a vector of terms
    // term_vec[j] = (~off_pwm_in[j]) & off_pwm_msk_i[OFF_PWM_CH_NUM*i + j]
    // then off_pwm_o_w[i] = |term_vec
    generate
        for (i = 0; i < OFF_PWM_CH_NUM; i = i + 1) begin : gen_i
            wire [OFF_PWM_CH_NUM-1:0] term_vec;
            for (j = 0; j < OFF_PWM_CH_NUM; j = j + 1) begin : gen_j
                // compute index into flattened mask vector
                // index = OFF_PWM_CH_NUM*i + j
                assign term_vec[j] = (~off_pwm_in[j]) & off_pwm_msk_i[OFF_PWM_CH_NUM*i+j];
            end
            assign off_pwm_o_w[i] = |term_vec;
        end
    endgenerate

    assign off_pwm_on = ~off_pwm_o_w;
endmodule
