module ae_case3 #(
    parameter integer SIG_I_NUM   = 18,
    parameter integer SIG_OFF_NUM = 3,
    // number of signals handled by each off block (must satisfy SIG_I_NUM == SIG_OFF_NUM * CH_PER_BLK)
    parameter integer CH_PER_BLK  = 6
) (
    input clk_i,
    input rst_ni,

    input [   SIG_OFF_NUM-1:0] sig_off_i,
    input [SIG_OFF_NUM**2-1:0] sig_off_msk_i,
    input [   SIG_OFF_NUM-1:0] sig_off_prot_mode_i,
    input [   SIG_OFF_NUM-1:0] sig_off_trig_mode_i,
    input [ SIG_OFF_NUM*2-1:0] sig_off_trig_pol_i,

    input sig_ctrl_loop_start_i,

    input  [SIG_I_NUM-1:0] sig_i,
    output [SIG_I_NUM-1:0] sig_o
);
    // off pwm protect mode
    parameter PROT_MODE_CBC = 1'b0;  //  0, cycle by cycle
    parameter PROT_MODE_OST = 1'b1;  //  1, oneshot

    wire [SIG_OFF_NUM-1:0] sig_off_w;

    reg  [SIG_OFF_NUM-1:0] sig_off_i_r;

    //ae_case3_off_pwm_ctrl #(
    //    .OFF_PWM_CH_NUM         ( SIG_OFF_NUM           )
    //) u_ae_case3_sig_off_ctrl (
    //    .clk_i                  ( clk_i                 ),
    //    .rst_ni                 ( rst_ni                ),
    //    .off_pwm_prot_mode_i    ( sig_off_prot_mode_i   ),   
    //    .off_pwm_trig_mode_i    ( sig_off_trig_mode_i   ),   
    //    .off_pwm_trig_pol_i     ( sig_off_trig_pol_i    ),           
    //    .pwm_ctrl_loop_start_i  ( sig_ctrl_loop_start_i ),     
    //    .off_pwm_msk_i          ( sig_off_msk_i         ), 
    //    .off_pwm_i              ( sig_off_i             ), 
    //    .off_pwm_o              ( sig_off_w             )         
    //);

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_off_i_r <= 3'd0;
        end else begin
            sig_off_i_r <= sig_off_i;
        end
    end

    assign sig_off_w = sig_off_i_r;

    sig_off_g1p6 #(
        .NUM_SIGS(CH_PER_BLK)
    ) u1_sig_off_g1p6 (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .sig_off_ni(sig_off_w[0]),
        .sig_i     (sig_i[CH_PER_BLK-1:0]),
        .sig_o     (sig_o[CH_PER_BLK-1:0])
    );

    sig_off_g1p6 #(
        .NUM_SIGS(CH_PER_BLK)
    ) u2_sig_off_g1p6 (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .sig_off_ni(sig_off_w[1]),
        .sig_i     (sig_i[CH_PER_BLK*2-1:CH_PER_BLK*1]),
        .sig_o     (sig_o[CH_PER_BLK*2-1:CH_PER_BLK*1])
    );

    sig_off_g1p6 #(
        .NUM_SIGS(CH_PER_BLK)
    ) u3_sig_off_g1p6 (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .sig_off_ni(sig_off_w[2]),
        .sig_i     (sig_i[CH_PER_BLK*3-1:CH_PER_BLK*2]),
        .sig_o     (sig_o[CH_PER_BLK*3-1:CH_PER_BLK*2])
    );
endmodule
