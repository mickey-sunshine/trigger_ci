module ae_case2 #(
    parameter integer PWM_NUM        = 18,
    parameter integer OFF_PWM_CH_NUM = 3
) (
    input clk_i,
    input rst_ni,

    input [  OFF_PWM_CH_NUM-1:0] off_pwm_prot_mode_i,
    input [  OFF_PWM_CH_NUM-1:0] off_pwm_trig_mode_i,
    input [OFF_PWM_CH_NUM*2-1:0] off_pwm_trig_pol_i,

    input                                        pwm_ctrl_loop_start_i,
    input  [(OFF_PWM_CH_NUM*OFF_PWM_CH_NUM)-1:0] off_pwm_msk_i,
    input  [                 OFF_PWM_CH_NUM-1:0] off_pwm_i,
    input  [                        PWM_NUM-1:0] pwm_i,
    output [                        PWM_NUM-1:0] pwm_o
);

    // off pwm protect mode
    // parameter PROT_MODE_CBC = 1'b0; //  0, cycle by cycle
    // parameter PROT_MODE_OST = 1'b1; //  1, oneshot

    wire [OFF_PWM_CH_NUM-1:0] off_pwm_w;

    parameter CNT_DIR_UP = 1'b0;
    parameter CNT_DIR_DOWN = 1'b1;


    // off_pwm_ctrl #(
    //     .OFF_PWM_CH_NUM         ( OFF_PWM_CH_NUM        )
    // ) u_off_pwm_ctrl (
    //     .clk_i                  ( clk_i                 ),
    //     .rst_ni                 ( rst_ni                ),
    //     .off_pwm_prot_mode_i    ( off_pwm_prot_mode_i   ),   
    //     .off_pwm_trig_mode_i    ( off_pwm_trig_mode_i   ),   
    //     .off_pwm_trig_pol_i     ( off_pwm_trig_pol_i    ),           
    //     .pwm_ctrl_loop_start_i  ( pwm_ctrl_loop_start_i ),     
    //     .off_pwm_msk_i          ( off_pwm_msk_i         ), 
    //     .off_pwm_i              ( off_pwm_i             ), 
    //     .off_pwm_o              ( off_pwm_w             )         
    // );

    pwm_protection_g1p6_16b #(
        .DATA_WIDTH          (6),
        .DLY_PWM21_CNT_DIR   (CNT_DIR_UP),
        .DLY_PWM21_LOAD_VALUE(16'd0),
        .DLY_PWM21_MATCH0_REF(16'd16),
        .DLY_PWM21_MATCH1_REF(16'd35),

        .DLY_PWM34_CNT_DIR   (CNT_DIR_UP),
        .DLY_PWM34_LOAD_VALUE(16'd0),
        .DLY_PWM34_MATCH0_REF(16'd21),
        .DLY_PWM34_MATCH1_REF(16'd39),

        .DLY_OFF13_CNT_DIR   (CNT_DIR_UP),
        .DLY_OFF13_LOAD_VALUE(16'd0),
        .DLY_OFF13_MATCH0_REF(16'd12),
        .DLY_OFF13_MATCH1_REF(16'd40),

        .DLY_OFF24_CNT_DIR   (CNT_DIR_UP),
        .DLY_OFF24_LOAD_VALUE(16'd0),
        .DLY_OFF24_MATCH0_REF(16'd23),
        .DLY_OFF24_MATCH1_REF(16'd49)
    ) u1_pwm_protection_g1p6_16b (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .pwm_i    (pwm_i[5:0]),
        .off_pwm_i(off_pwm_i[0]),
        .pwm_o    (pwm_o[5:0])
    );

    pwm_protection_g1p6_16b #(
        .DATA_WIDTH          (6),
        .DLY_PWM21_CNT_DIR   (CNT_DIR_UP),
        .DLY_PWM21_LOAD_VALUE(16'd0),
        .DLY_PWM21_MATCH0_REF(16'd26),
        .DLY_PWM21_MATCH1_REF(16'd35),

        .DLY_PWM34_CNT_DIR   (CNT_DIR_UP),
        .DLY_PWM34_LOAD_VALUE(16'd0),
        .DLY_PWM34_MATCH0_REF(16'd11),
        .DLY_PWM34_MATCH1_REF(16'd20),

        .DLY_OFF13_CNT_DIR   (CNT_DIR_UP),
        .DLY_OFF13_LOAD_VALUE(16'd0),
        .DLY_OFF13_MATCH0_REF(16'd20),
        .DLY_OFF13_MATCH1_REF(16'd32),

        .DLY_OFF24_CNT_DIR   (CNT_DIR_UP),
        .DLY_OFF24_LOAD_VALUE(16'd0),
        .DLY_OFF24_MATCH0_REF(16'd13),
        .DLY_OFF24_MATCH1_REF(16'd46)
    ) u2_pwm_protection_g1p6_16b (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .pwm_i    (pwm_i[11:6]),
        .off_pwm_i(off_pwm_i[1]),
        .pwm_o    (pwm_o[11:6])
    );

    pwm_protection_g1p6_16b #(
        .DATA_WIDTH          (6),
        .DLY_PWM21_CNT_DIR   (CNT_DIR_UP),
        .DLY_PWM21_LOAD_VALUE(16'd0),
        .DLY_PWM21_MATCH0_REF(16'd8),
        .DLY_PWM21_MATCH1_REF(16'd15),

        .DLY_PWM34_CNT_DIR   (CNT_DIR_UP),
        .DLY_PWM34_LOAD_VALUE(16'd0),
        .DLY_PWM34_MATCH0_REF(16'd28),
        .DLY_PWM34_MATCH1_REF(16'd31),

        .DLY_OFF13_CNT_DIR   (CNT_DIR_UP),
        .DLY_OFF13_LOAD_VALUE(16'd0),
        .DLY_OFF13_MATCH0_REF(16'd12),
        .DLY_OFF13_MATCH1_REF(16'd23),

        .DLY_OFF24_CNT_DIR   (CNT_DIR_UP),
        .DLY_OFF24_LOAD_VALUE(16'd0),
        .DLY_OFF24_MATCH0_REF(16'd24),
        .DLY_OFF24_MATCH1_REF(16'd47)
    ) u3_pwm_protection_g1p6_16b (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .pwm_i    (pwm_i[17:12]),
        .off_pwm_i(off_pwm_i[2]),
        .pwm_o    (pwm_o[17:12])
    );

endmodule
