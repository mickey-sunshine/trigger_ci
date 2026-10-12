module ae_case1 (
    input clk_i,
    input rst_ni,
    input epwm_1a_i,
    input epwm_1b_i,
    output wire EPWM_2A_o,
    output wire EPWM_2B_o
);

    wire rst_pulse;

    reg int_rstn, int_rstn_1;

    wire pcntA_match0_w;
    wire pcntA_match1_w;
    wire pcntB_match0_w;
    wire pcntB_match1_w;

    reg pcntA_match0_r;
    reg pcntA_match1_r;
    reg pcntB_match0_r;
    reg pcntB_match1_r;
    reg pcntA_event_r;
    reg pcntB_event_r;
    reg epwm_1a_p_fsm_r;
    reg epwm_1b_p_fsm_r;

    wire trig_signal0;
    wire trig_signal1;

    wire epwm_1a_n;
    wire epwm_1a_p;
    wire epwm_1b_n;
    wire epwm_1b_p;

    reg [1:0] epwm_1a_pipe_r;
    reg [1:0] epwm_1b_pipe_r;

    wire epwm_2a;
    wire epwm_2b;

    // Keep a dedicated fabric-side result register between the FSM and the
    // logic-free IO boundary register.  The FSM must stay close to the fixed
    // PCNT blocks, while the result register is free to move toward the pad.
    reg epwm_2a_result_r;
    reg epwm_2b_result_r;
    reg epwm_2a_out_r;
    reg epwm_2b_out_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            epwm_2a_result_r <= 1'b0;
            epwm_2b_result_r <= 1'b1;
            epwm_2a_out_r <= 1'b0;
            epwm_2b_out_r <= 1'b1;
        end else begin
            epwm_2a_result_r <= epwm_2a;
            epwm_2b_result_r <= ~epwm_2b;
            epwm_2a_out_r <= epwm_2a_result_r;
            epwm_2b_out_r <= epwm_2b_result_r;
        end
    end

    assign EPWM_2A_o = epwm_2a_out_r;
    assign EPWM_2B_o = epwm_2b_out_r;

    // Share one two-stage input pipeline per PWM input.  The first stage is a
    // direct input register and can be absorbed into the input IO FF; deriving
    // both edges from the same pipeline avoids two duplicated pad-to-CLB paths.
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            epwm_1a_pipe_r <= 2'b00;
            epwm_1b_pipe_r <= 2'b00;
        end else begin
            epwm_1a_pipe_r <= {epwm_1a_pipe_r[0], epwm_1a_i};
            epwm_1b_pipe_r <= {epwm_1b_pipe_r[0], epwm_1b_i};
        end
    end

    assign epwm_1a_p = epwm_1a_pipe_r[0] & ~epwm_1a_pipe_r[1];
    assign epwm_1a_n = ~epwm_1a_pipe_r[0] & epwm_1a_pipe_r[1];
    assign epwm_1b_p = epwm_1b_pipe_r[0] & ~epwm_1b_pipe_r[1];
    assign epwm_1b_n = ~epwm_1b_pipe_r[0] & epwm_1b_pipe_r[1];

    // internal reset logic
    always @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            int_rstn   <= 1'b0;
            int_rstn_1 <= 1'b0;
        end else begin
            int_rstn   <= 1'b1;
            int_rstn_1 <= int_rstn;
        end
    end

    /*-----------------------------------------------------------
                        user logic
    -----------------------------------------------------------*/

    // The registered PCNT match boundary adds one clock.  Program each hard
    // counter one count early so the externally observed match points remain
    // equivalent to the original 250/10-cycle settings.
    // match0(249 + 1 pipeline) = 原半周期延时 250
    // match1(9 + 1 pipeline)   = 原死区延时 10
    // 由于 epwm_1a_i/1b_i 严格互斥，上升沿和下降沿不会同时出现，
    // 同一计数器可安全处理两种边沿事件
    assign trig_signal0 = pcntA_match0_r | pcntA_match1_r;
    assign trig_signal1 = pcntB_match0_r | pcntB_match1_r;

    // Register both sides of the fixed PCNT blocks.  The hard counters are
    // physically distant from the small control FSM, so direct LUT/FF-to-PCNT
    // and PCNT-to-FSM connections are dominated by routing delay.
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pcntA_event_r   <= 1'b0;
            pcntB_event_r   <= 1'b0;
            epwm_1a_p_fsm_r <= 1'b0;
            epwm_1b_p_fsm_r <= 1'b0;
            pcntA_match0_r  <= 1'b0;
            pcntA_match1_r  <= 1'b0;
            pcntB_match0_r  <= 1'b0;
            pcntB_match1_r  <= 1'b0;
        end else begin
            // Use the PCNT synchronous load event for the post-reset restart.
            // Do not create a routed combinational pulse on the asynchronous
            // reset pin of a fixed hard counter.
            pcntA_event_r   <= epwm_1a_p | epwm_1a_n | rst_pulse;
            pcntB_event_r   <= epwm_1b_p | epwm_1b_n | rst_pulse;
            epwm_1a_p_fsm_r <= epwm_1a_p;
            epwm_1b_p_fsm_r <= epwm_1b_p;
            pcntA_match0_r  <= pcntA_match0_w;
            pcntA_match1_r  <= pcntA_match1_w;
            pcntB_match0_r  <= pcntB_match0_w;
            pcntB_match1_r  <= pcntB_match1_w;
        end
    end

    sr_fsm epwm_1a_fsm_inst (
        .clk(clk_i),
        .rst_n(rst_ni),
        .E0(epwm_1a_p_fsm_r),
        .E1(trig_signal0),
        .S0(epwm_2a)
    );

    sr_fsm epwm_1b_fsm_inst (
        .clk(clk_i),
        .rst_n(rst_ni),
        .E0(epwm_1b_p_fsm_r),
        .E1(trig_signal1),
        .S0(epwm_2b)
    );

    // pcntA: 合并 pcnt0(上升沿,ref=250) + pcnt2(下降沿,ref=10)
    pcounter32_clkp_arstn_load #(
        .MATCH0_REF(32'd249),
        .MATCH1_REF(32'd9)
    ) pcntA (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(pcntA_event_r),
        .enable_i(1'b1),
        .match0_o(pcntA_match0_w),
        .match1_o(pcntA_match1_w),
        .zero_o()
    );

    // pcntB: 合并 pcnt1(上升沿,ref=250) + pcnt3(下降沿,ref=10)
    pcounter32_clkp_arstn_load #(
        .MATCH0_REF(32'd249),
        .MATCH1_REF(32'd9)
    ) pcntB (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(pcntB_event_r),
        .enable_i(1'b1),
        .match0_o(pcntB_match0_w),
        .match1_o(pcntB_match1_w),
        .zero_o()
    );

    // internal reset pulse
    rf_pulse_gen u_rst_pulse_gen (
        .clk_i   (clk_i),
        .rst_ni  (rst_ni),
        .signal_i(int_rstn_1),
        .pulse_o (rst_pulse)
    );

endmodule
