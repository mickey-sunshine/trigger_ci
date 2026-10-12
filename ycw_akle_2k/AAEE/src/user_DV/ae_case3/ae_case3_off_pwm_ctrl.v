//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/23 15:44:46
// Design Name: 
// Module Name: off_pwm_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.2.0 - Added CBC mode control logic 
//      Added a delay in CBC mode where, after receiving fault information and recovery, 
//      the PWM_O output resumes at the start of the next PWM control cycle.
// Revision 0.1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ae_case3_off_pwm_ctrl #(
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

    wire [OFF_PWM_CH_NUM-1:0] off_pwm_w;
    // temporary output mirror that applies delayed rising behavior
    reg  [OFF_PWM_CH_NUM-1:0] off_pwm_tmp_r;
    // Registered copy of off_pwm_w to break combinational paths (timing)
    reg  [OFF_PWM_CH_NUM-1:0] off_pwm_w_r;
    reg                       pwm_ctrl_loop_start_i_r;


    ae_case3_off_pwm_mode_ctrl u_ae_case3_off_pwm_mode_ctrl_g1 (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .off_pwm_prot_mode_i(off_pwm_prot_mode_i[0]),
        .off_pwm_trig_mode_i(off_pwm_trig_mode_i[0]),
        .off_pwm_trig_pol_i (off_pwm_trig_pol_i[1:0]),
        .off_pwm_i          (off_pwm_i[0]),
        .off_pwm_o          (off_pwm_w[0])
    );

    ae_case3_off_pwm_mode_ctrl u_ae_case3_off_pwm_mode_ctrl_g2 (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .off_pwm_prot_mode_i(off_pwm_prot_mode_i[1]),
        .off_pwm_trig_mode_i(off_pwm_trig_mode_i[1]),
        .off_pwm_trig_pol_i (off_pwm_trig_pol_i[3:2]),
        .off_pwm_i          (off_pwm_i[1]),
        .off_pwm_o          (off_pwm_w[1])
    );

    ae_case3_off_pwm_mode_ctrl u_ae_case3_off_pwm_mode_ctrl_g3 (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .off_pwm_prot_mode_i(off_pwm_prot_mode_i[2]),
        .off_pwm_trig_mode_i(off_pwm_trig_mode_i[2]),
        .off_pwm_trig_pol_i (off_pwm_trig_pol_i[5:4]),
        .off_pwm_i          (off_pwm_i[2]),
        .off_pwm_o          (off_pwm_w[2])
    );


    ae_case3_off_pwm_sel #(
        .OFF_PWM_CH_NUM(OFF_PWM_CH_NUM)
    ) u_ae_case3_off_pwm_sel (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .off_pwm_msk_i(off_pwm_msk_i),
        // feed the selector with the temporary signal which implements
        // the "wait-for-pwm_ctrl_loop_start_i" semantics on rising edges
        .off_pwm_in   (off_pwm_tmp_r),
        .off_pwm_on   (off_pwm_o)
    );

    // ------------------------------------------------------------------
    // off_pwm_tmp_r behavior:
    // - when off_pwm_w bit is 0 -> off_pwm_tmp_r follows (0) immediately
    // - when off_pwm_w bit is 1 and off_pwm_tmp_r is 0 -> it will only
    //   be raised to 1 on the rising edge of pwm_ctrl_loop_start_i
    // - when off_pwm_w bit is 1 and off_pwm_tmp_r already 1 -> remain 1
    // Initialize off_pwm_tmp_r to off_pwm_w on reset.
    // ------------------------------------------------------------------
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            // Do not sample combinational output wires during reset.
            // Initialize temporary vector to a safe default (all '1') so
            // that when normal operation resumes the tmp vector will
            // follow off_pwm_w on the next clock cycle.
            off_pwm_tmp_r <= {OFF_PWM_CH_NUM{1'b1}};
            off_pwm_w_r <= {OFF_PWM_CH_NUM{1'b1}};
            pwm_ctrl_loop_start_i_r <= 1'b0;
        end else begin
            // sample control pulse edge
            pwm_ctrl_loop_start_i_r <= pwm_ctrl_loop_start_i;

            // register the combinational outputs from channel modules to
            // shorten the path into the tmp logic (one-cycle latency)
            off_pwm_w_r <= off_pwm_w;

            // rising detect (scalar) replicated to bits
            // next tmp = registered_off_pwm_w & (off_pwm_tmp_r | {N{rising}})
            off_pwm_tmp_r <= (off_pwm_w_r & (off_pwm_tmp_r | {OFF_PWM_CH_NUM{(pwm_ctrl_loop_start_i & ~pwm_ctrl_loop_start_i_r)}}));
        end
    end

endmodule
