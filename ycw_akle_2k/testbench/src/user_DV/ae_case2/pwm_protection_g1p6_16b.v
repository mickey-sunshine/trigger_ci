module pwm_protection_g1p6_16b #(
    parameter DATA_WIDTH = 16,

    parameter DLY_PWM21_CNT_DIR    = 1'b0,
    parameter DLY_PWM21_LOAD_VALUE = {DATA_WIDTH{1'b0}},
    parameter DLY_PWM21_MATCH0_REF = {DATA_WIDTH{1'b0}},
    parameter DLY_PWM21_MATCH1_REF = {DATA_WIDTH{1'b0}},

    parameter DLY_PWM34_CNT_DIR    = 1'b0,
    parameter DLY_PWM34_LOAD_VALUE = {DATA_WIDTH{1'b0}},
    parameter DLY_PWM34_MATCH0_REF = {DATA_WIDTH{1'b0}},
    parameter DLY_PWM34_MATCH1_REF = {DATA_WIDTH{1'b0}},

    parameter DLY_OFF13_CNT_DIR    = 1'b0,
    parameter DLY_OFF13_LOAD_VALUE = {DATA_WIDTH{1'b0}},
    parameter DLY_OFF13_MATCH0_REF = {DATA_WIDTH{1'b0}},
    parameter DLY_OFF13_MATCH1_REF = {DATA_WIDTH{1'b0}},

    parameter DLY_OFF24_CNT_DIR    = 1'b0,
    parameter DLY_OFF24_LOAD_VALUE = {DATA_WIDTH{1'b0}},
    parameter DLY_OFF24_MATCH0_REF = {DATA_WIDTH{1'b0}},
    parameter DLY_OFF24_MATCH1_REF = {DATA_WIDTH{1'b0}}
) (
    input  wire                  clk_i,
    input  wire                  rst_ni,
    input  wire [DATA_WIDTH-1:0] pwm_i,
    input  wire                  off_pwm_i,
    output wire [DATA_WIDTH-1:0] pwm_o
);

    // ============================================================
    // Stage 0: input register
    // ============================================================

    reg [DATA_WIDTH-1:0] pwm_s0;
    reg                  off_s0;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_s0 <= {DATA_WIDTH{1'b0}};
            off_s0 <= 1'b0;
        end else begin
            pwm_s0 <= pwm_i;
            off_s0 <= off_pwm_i;
        end
    end


    // ============================================================
    // Stage 1: register simple protection logic before delay blocks
    // This cuts path:
    // pwm_i_r -> pwm1_100_w / pwm4_100_w -> signal_dly_ctrl
    // ============================================================

    reg [DATA_WIDTH-1:0] pwm_s1;
    reg                  off_s1;

    reg                  pwm21_sig1_s1;
    reg                  pwm21_sig2_s1;
    reg                  pwm34_sig1_s1;
    reg                  pwm34_sig2_s1;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_s1        <= {DATA_WIDTH{1'b0}};
            off_s1        <= 1'b0;

            pwm21_sig1_s1 <= 1'b0;
            pwm21_sig2_s1 <= 1'b0;
            pwm34_sig1_s1 <= 1'b0;
            pwm34_sig2_s1 <= 1'b0;
        end else begin
            pwm_s1        <= pwm_s0;
            off_s1        <= off_s0;

            pwm21_sig1_s1 <= pwm_s0[1];
            pwm21_sig2_s1 <= pwm_s0[0] & ~pwm_s0[3];

            pwm34_sig1_s1 <= pwm_s0[2];
            pwm34_sig2_s1 <= pwm_s0[3] & ~pwm_s0[0];
        end
    end


    // ============================================================
    // Delay control block outputs
    // ============================================================

    wire pwm21_sig1_dly_w;
    wire pwm21_sig2_dly_w;
    wire pwm34_sig1_dly_w;
    wire pwm34_sig2_dly_w;

    wire off_dly_1_w;
    wire off_dly_2_w;
    wire off_dly_3_w;
    wire off_dly_4_w;


    signal_dly_ctrl #(
        .LOAD_VALUE(DLY_PWM21_LOAD_VALUE),
        .MATCH0_REF(DLY_PWM21_MATCH0_REF),
        .MATCH1_REF(DLY_PWM21_MATCH1_REF)
    ) u21_signal_dly_ctrl (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .cnt_dir_i (DLY_PWM21_CNT_DIR),
        .signal_1_i(pwm21_sig1_s1),
        .signal_2_i(pwm21_sig2_s1),
        .signal_1_o(pwm21_sig1_dly_w),
        .signal_2_o(pwm21_sig2_dly_w)
    );


    signal_dly_ctrl #(
        .LOAD_VALUE(DLY_PWM34_LOAD_VALUE),
        .MATCH0_REF(DLY_PWM34_MATCH0_REF),
        .MATCH1_REF(DLY_PWM34_MATCH1_REF)
    ) u34_signal_dly_ctrl (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .cnt_dir_i (DLY_PWM34_CNT_DIR),
        .signal_1_i(pwm34_sig1_s1),
        .signal_2_i(pwm34_sig2_s1),
        .signal_1_o(pwm34_sig1_dly_w),
        .signal_2_o(pwm34_sig2_dly_w)
    );


    /*
     * 注意：
     * 你原代码中 signal_dly_ctrl_pipeline 的 signal_2_i 是空接：
     *
     *     .signal_2_i ( )
     *
     * 但后面又使用了 signal_2_o：
     *
     *     off_pwm_400_dly_3_w
     *     off_pwm_400_dly_4_w
     *
     * 如果 signal_2_o 预期也是 off_pwm_i 的延迟版本，
     * 这里建议显式连接 off_s1。
     * 如果你的 signal_dly_ctrl_pipeline 内部不使用 signal_2_i，
     * 可以根据实际 RTL 再调整。
     */

    signal_dly_ctrl_pipeline #(
        .LOAD_VALUE(DLY_OFF13_LOAD_VALUE),
        .MATCH0_REF(DLY_OFF13_MATCH0_REF),
        .MATCH1_REF(DLY_OFF13_MATCH1_REF)
    ) u13_signal_dly_ctrl_pipeline (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .cnt_dir_i (DLY_OFF13_CNT_DIR),
        .signal_1_i(off_s1),
        .signal_2_i(off_s1),
        .signal_1_o(off_dly_1_w),
        .signal_2_o(off_dly_3_w)
    );


    signal_dly_ctrl_pipeline #(
        .LOAD_VALUE(DLY_OFF24_LOAD_VALUE),
        .MATCH0_REF(DLY_OFF24_MATCH0_REF),
        .MATCH1_REF(DLY_OFF24_MATCH1_REF)
    ) u24_signal_dly_ctrl_pipeline (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .cnt_dir_i (DLY_OFF24_CNT_DIR),
        .signal_1_i(off_s1),
        .signal_2_i(off_s1),
        .signal_1_o(off_dly_2_w),
        .signal_2_o(off_dly_4_w)
    );


    // ============================================================
    // Stage 2: register delay block outputs
    // This cuts path:
    // signal_dly_ctrl output -> final AND/OR output logic
    // ============================================================

    reg [DATA_WIDTH-1:0] pwm_s2;
    reg                  off_s2;

    reg                  pwm_o_0_s2;
    reg                  pwm_o_1_s2;
    reg                  pwm_o_2_s2;
    reg                  pwm_o_3_s2;

    reg                  off_dly_1_s2;
    reg                  off_dly_2_s2;
    reg                  off_dly_3_s2;
    reg                  off_dly_4_s2;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_s2       <= {DATA_WIDTH{1'b0}};
            off_s2       <= 1'b0;

            pwm_o_0_s2   <= 1'b0;
            pwm_o_1_s2   <= 1'b0;
            pwm_o_2_s2   <= 1'b0;
            pwm_o_3_s2   <= 1'b0;

            off_dly_1_s2 <= 1'b0;
            off_dly_2_s2 <= 1'b0;
            off_dly_3_s2 <= 1'b0;
            off_dly_4_s2 <= 1'b0;
        end else begin
            pwm_s2       <= pwm_s1;
            off_s2       <= off_s1;

            pwm_o_0_s2   <= pwm21_sig2_dly_w;
            pwm_o_1_s2   <= pwm21_sig1_dly_w;
            pwm_o_2_s2   <= pwm34_sig1_dly_w;
            pwm_o_3_s2   <= pwm34_sig2_dly_w;

            off_dly_1_s2 <= off_dly_1_w;
            off_dly_2_s2 <= off_dly_2_w;
            off_dly_3_s2 <= off_dly_3_w;
            off_dly_4_s2 <= off_dly_4_w;
        end
    end


    // ============================================================
    // Stage 3: compute the protected PWM result in the fabric.
    // Keep this register separate from the I/O-facing register below so the
    // final AND/OR logic does not have to route directly into an output IO FF.
    // ============================================================

    reg [DATA_WIDTH-1:0] pwm_result_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_result_r <= {DATA_WIDTH{1'b0}};
        end else begin
            pwm_result_r <= {DATA_WIDTH{1'b0}};

            pwm_result_r[0] <= pwm_o_0_s2 & off_s2;
            pwm_result_r[1] <= pwm_o_1_s2 & off_dly_1_s2;
            pwm_result_r[2] <= pwm_o_2_s2 & off_dly_2_s2;
            pwm_result_r[3] <= pwm_o_3_s2 & off_s2;

            pwm_result_r[4] <= pwm_s2[4] | ((~off_s2) & off_dly_3_s2);
            pwm_result_r[5] <= pwm_s2[5] | ((~off_s2) & off_dly_4_s2);
        end
    end

    // Stage 4: I/O boundary register.  This stage contains no logic and can
    // therefore be absorbed into the output IO FF by VPR.
    reg [DATA_WIDTH-1:0] pwm_o_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_o_r <= {DATA_WIDTH{1'b0}};
        end else begin
            pwm_o_r <= pwm_result_r;
        end
    end

    assign pwm_o = pwm_o_r;

endmodule
