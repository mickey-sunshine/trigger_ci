module signal_dly_ctrl_pipeline #(
    parameter integer DATA_WIDTH = 16,
    parameter [DATA_WIDTH-1:0] LOAD_VALUE = {DATA_WIDTH{1'b0}},
    parameter [DATA_WIDTH-1:0] MATCH0_REF = 8,
    parameter [DATA_WIDTH-1:0] MATCH1_REF = 18
) (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire cnt_dir_i,
    input  wire signal_1_i,
    input  wire signal_2_i,
    output wire signal_1_o,
    output wire signal_2_o
);

    wire edge_p_w;
    wire edge_n_w;

    wire evt_match0_w;
    wire evt_match1_w;

    reg  sig_ena_r;
    reg  off_dly_400_1_r;
    reg  off_dly_400_2_r;

    // Isolate both sides of the hard counter.  The counter control inputs and
    // match outputs are registered so no LUT cone or high-fanout state net has
    // to cross the fabric directly into/out of the fixed PCNT location.
    reg  edge_p_pipe_r;
    reg  edge_n_pipe_r;
    reg  cnt_enable_pipe_r;
    reg  match0_pipe_r;
    reg  match1_pipe_r;

    edge_detection u_edge_detection (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .signal_i     (signal_1_i),
        .edge_p_trig_o(edge_p_w),
        .edge_n_trig_o(edge_n_w)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            edge_p_pipe_r    <= 1'b0;
            edge_n_pipe_r    <= 1'b0;
            cnt_enable_pipe_r <= 1'b0;
            match0_pipe_r    <= 1'b0;
            match1_pipe_r    <= 1'b0;
        end else begin
            edge_p_pipe_r     <= edge_p_w;
            edge_n_pipe_r     <= edge_n_w;
            cnt_enable_pipe_r <= (sig_ena_r | edge_n_w) & ~edge_p_w;
            match0_pipe_r     <= evt_match0_w;
            match1_pipe_r     <= evt_match1_w;
        end
    end

    pcounter16_clkp_arstn_load #(
        .LOAD_VAL  (LOAD_VALUE),
        .MATCH0_REF(MATCH0_REF),
        .MATCH1_REF(MATCH1_REF)
    ) u_pcounter16_clkp_arstn_sr (
        .clk_i    (clk_i),
        .rst_i    (rst_ni),             // 请确认该端口是否为低有效复位
        .up_down_i(cnt_dir_i),
        .event_i  (edge_n_pipe_r),
        .enable_i (cnt_enable_pipe_r),
        .match0_o (evt_match0_w),
        .match1_o (evt_match1_w),
        .zero_o   ()
    );

    /*
     * match 有效条件：
     * 1. 当前处于计数使能状态；
     * 2. 当前不是上升沿清零周期；
     * 3. 当前不是新的下降沿重载周期，避免旧计数器状态产生误触发。
     */
    wire match0_valid_w;
    wire match1_valid_w;

    assign match0_valid_w = sig_ena_r & ~edge_p_pipe_r & ~edge_n_pipe_r & match0_pipe_r;
    assign match1_valid_w = sig_ena_r & ~edge_p_pipe_r & ~edge_n_pipe_r & match1_pipe_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_ena_r       <= 1'b0;
            off_dly_400_1_r <= 1'b0;
            off_dly_400_2_r <= 1'b0;
        end else begin
            /*
             * 上升沿优先级最高：
             * 输入重新有效时，立即恢复输出，并终止当前计数。
             */
            if (edge_p_pipe_r) begin
                sig_ena_r       <= 1'b0;
                off_dly_400_1_r <= 1'b0;
                off_dly_400_2_r <= 1'b0;
            end else begin
                /*
                 * 下降沿启动或重启计数。
                 * 如果 match1 和新的下降沿同拍出现，以新的下降沿为准。
                 */
                if (edge_n_pipe_r) begin
                    sig_ena_r <= 1'b1;
                end else if (match1_valid_w) begin
                    sig_ena_r <= 1'b0;
                end

                if (match0_valid_w) begin
                    off_dly_400_1_r <= 1'b1;
                end

                if (match1_valid_w) begin
                    off_dly_400_2_r <= 1'b1;
                end
            end
        end
    end

    assign signal_1_o = ~off_dly_400_1_r;
    assign signal_2_o = ~off_dly_400_2_r;

endmodule

module signal_dly_ctrl #(
    parameter DATA_WIDTH = 16,
    parameter LOAD_VALUE = 16'd0,
    parameter MATCH0_REF = 16'd8,
    parameter MATCH1_REF = 16'd18,

    // 1: 输出寄存，时序更好，但 signal_1_o/signal_2_o 增加 1 个 clk 延迟
    // 0: 保持原组合输出行为
    parameter REGISTER_OUTPUT = 1
) (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire cnt_dir_i,
    input  wire signal_1_i,
    input  wire signal_2_i,
    output wire signal_1_o,
    output wire signal_2_o
);

    wire edge_p_w;
    wire edge_n_w;

    wire evt_trig_w;
    wire evt_match0_w;
    wire evt_match1_w;
    wire evt_zero_unused_w;

    wire signal_2_200_c;
    wire signal_1_300_c;

    reg  sig_ena_r;
    reg  signal_1_dly_200_r;
    reg  signal_2_dly_300_r;
    reg  evt_trig_pipe_r;
    reg  match0_pipe_r;
    reg  match1_pipe_r;

    assign evt_trig_w = edge_p_w | edge_n_w;

    edge_detection u_edge_detection (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .signal_i     (signal_1_i),
        .edge_p_trig_o(edge_p_w),
        .edge_n_trig_o(edge_n_w)
    );

    // Register the hard-counter boundary.  This adds deterministic latency but
    // prevents an edge-detect LUT from directly driving PCNT event_i and
    // prevents PCNT match outputs from directly driving downstream LUT cones.
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            evt_trig_pipe_r <= 1'b0;
            match0_pipe_r   <= 1'b0;
            match1_pipe_r   <= 1'b0;
        end else begin
            evt_trig_pipe_r <= evt_trig_w;
            match0_pipe_r   <= evt_match0_w;
            match1_pipe_r   <= evt_match1_w;
        end
    end

    // 保持原 case 行为：
    // {evt_match1_w, evt_trig_w} = 2'b01 -> set
    // {evt_match1_w, evt_trig_w} = 2'b10 -> clear
    // {evt_match1_w, evt_trig_w} = 2'b00/2'b11 -> hold
    wire sig_ena_set_w = evt_trig_pipe_r & ~match1_pipe_r;
    wire sig_ena_clr_w = match1_pipe_r & ~evt_trig_pipe_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_ena_r <= 1'b0;
        end else if (sig_ena_set_w) begin
            sig_ena_r <= 1'b1;
        end else if (sig_ena_clr_w) begin
            sig_ena_r <= 1'b0;
        end
    end

    pcounter16_clkp_arstn_load #(
        .LOAD_VAL  (LOAD_VALUE),
        .MATCH0_REF(MATCH0_REF),
        .MATCH1_REF(MATCH1_REF)
    ) u_pcounter16_clkp_arstn_sr (
        .clk_i    (clk_i),
        .rst_i    (rst_ni),
        .up_down_i(cnt_dir_i),
        .event_i  (evt_trig_pipe_r),
        .enable_i (sig_ena_r),
        .match0_o (evt_match0_w),
        .match1_o (evt_match1_w),
        .zero_o   (evt_zero_unused_w)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_1_dly_200_r <= 1'b0;
        end else if (match0_pipe_r) begin
            signal_1_dly_200_r <= signal_1_i;
        end
    end

    assign signal_2_200_c = signal_1_dly_200_r & signal_2_i;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_2_dly_300_r <= 1'b0;
        end else if (match1_pipe_r) begin
            signal_2_dly_300_r <= signal_2_200_c;
        end
    end

    assign signal_1_300_c = signal_2_dly_300_r | signal_1_i;

    generate
        if (REGISTER_OUTPUT) begin : g_reg_output

            reg signal_1_o_r;
            reg signal_2_o_r;

            always @(posedge clk_i or negedge rst_ni) begin
                if (!rst_ni) begin
                    signal_1_o_r <= 1'b0;
                    signal_2_o_r <= 1'b0;
                end else begin
                    signal_1_o_r <= signal_1_300_c;
                    signal_2_o_r <= signal_2_200_c;
                end
            end

            assign signal_1_o = signal_1_o_r;
            assign signal_2_o = signal_2_o_r;

        end else begin : g_comb_output

            assign signal_1_o = signal_1_300_c;
            assign signal_2_o = signal_2_200_c;

        end
    endgenerate

endmodule
