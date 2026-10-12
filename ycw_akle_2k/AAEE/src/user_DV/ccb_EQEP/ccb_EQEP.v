/* UTF-8 */
module ccb_EQEP (
    input       clk_i,      // 输入时钟
    input       rst_ni,     // 输入复位信号
    input       EQEP_A_i,   // EQEP_A
    input       EQEP_B_i,   // EQEP_B
    input       EQEP_I_i,   // EQEP_I
    output wire wdt_o,      // 定期检测信号
    output reg  dir_o,      // 输出转动方向, 0 表示逆时针, 1 表示顺时针
    output wire error_o,    // 出现错误中断
    output wire counter_o,  // 避免counter被优化
    output reg  qclk_o,     // 输出QCLK便于观测
    output reg  rst_zero_o  // 输出reset_zero便于观测
);

    parameter MOD_SEL_QDU = 2'b00;      // 正交解码器(QDU) 功能选择(暂时只支持00) 00:正交计数 01:方向计数 10:递增计数 11:递减计数
    parameter MOD_SEL_IN = 1'b0;  // 输入模式选择 0:QEP 1:CW/CCW
    parameter CNT_RST_MODE = 2'b00;     // 计数器复位模式选择(暂时只支持00) 00:EQEP_I触发 01:计数到最大值 10:第一个索引值 11:单位超时
    parameter CNT_MAX_VAL = 32'd32;  // 计数器最大值
    parameter WDT_MAX_VAL = 32'd10;  // 计数器最大值
    reg dir_err;
    reg cnt_rst_event;
    assign error_o = dir_err;

    // reg qclk_o;
    reg edge_a, edge_b;
    reg EQEP_A_d1, EQEP_B_d1;
    reg [1:0] state, state_d1;
    /* 正交解码单元(QDU) */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            qclk_o <= 1'b0;
            edge_a <= 1'b0;
            edge_b <= 1'b0;
            EQEP_A_d1 <= 1'b0;
            EQEP_B_d1 <= 1'b0;
            state <= 2'b00;
            state_d1 <= 2'b00;
        end else begin
            EQEP_A_d1 <= EQEP_A_i;
            EQEP_B_d1 <= EQEP_B_i;
            edge_a <= EQEP_A_i ^ EQEP_A_d1;
            edge_b <= EQEP_B_i ^ EQEP_B_d1;
            qclk_o <= edge_a | edge_b;
            if (qclk_o) begin
                state <= {EQEP_A_d1, EQEP_B_d1};
                state_d1 <= state;
            end
        end
    end
    /* 方向检测 */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            dir_o   <= 1'b0;
            dir_err <= 1'b0;
        end else begin
            case (state)
                2'b00: begin
                    if (state_d1 == 2'b01) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b10) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b11) begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end else begin  // keep
                        dir_o   <= dir_o;
                        dir_err <= dir_err;
                    end
                end
                2'b01: begin
                    if (state_d1 == 2'b11) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b00) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b10) begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end else begin  // keep
                        dir_o   <= dir_o;
                        dir_err <= dir_err;
                    end
                end
                2'b10: begin
                    if (state_d1 == 2'b00) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b11) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b01) begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end else begin  // keep
                        dir_o   <= dir_o;
                        dir_err <= dir_err;
                    end
                end
                2'b11: begin
                    if (state_d1 == 2'b10) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b01) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b00) begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end else begin  // keep
                        dir_o   <= dir_o;
                        dir_err <= dir_err;
                    end
                end
                default: begin
                    dir_o   <= 1'b0;
                    dir_err <= 1'b1;
                end

            endcase
        end
    end
    /* reset event */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            cnt_rst_event <= 1'b1;
        end else begin
            case (CNT_RST_MODE)  // only mode 0 is supported now
                2'b00: begin  // when EQEP_I_i is high, reset event occurs
                    if (EQEP_I_i == 1'b1) cnt_rst_event <= 1'b1;
                    else cnt_rst_event <= 1'b0;
                end
                default: begin
                    cnt_rst_event <= 1'b0;
                end
            endcase
        end
    end

    // reg rst_zero_o;
    reg rst_max;

    always @(posedge qclk_o or negedge rst_ni) begin
        if (!rst_ni) begin
            rst_zero_o <= 1'b0;
        end else begin
            if (error_o == 1'b1) begin
                rst_zero_o <= 1'b0;  // 仅持续一个qclk_o
            end else if (rst_zero_o == 1'b0) begin
                rst_zero_o <= 1'b1;
            end else begin
                if (dir_o == 1'b1) begin
                    rst_zero_o <= ~cnt_rst_event;
                end else begin
                    rst_zero_o <= 1'b1;
                end
            end
        end
    end
    always @(posedge qclk_o or negedge rst_ni) begin
        if (!rst_ni) begin
            rst_max <= 1'b0;
        end else begin
            if (rst_max == 1'b1) begin
                rst_max <= 1'b0;  // 仅持续一个qclk_o
            end else begin
                if (dir_o == 1'b1) begin
                    rst_max <= 1'b0;
                end else begin
                    rst_max <= cnt_rst_event;
                end
            end
        end
    end

    /* counter */
    pcounter32_clkp_arstn_load #(
        .LOAD_VAL(CNT_MAX_VAL)
    ) pcnt_pos (
        .clk_i(clk_i),
        .rst_i(rst_zero_o),  // when clockwise, reset to zero
        .up_down_i(~dir_o),
        .event_i(rst_max),  // when conter clockwise, reset to max
        .enable_i(qclk_o),
        .match0_o(),
        .match1_o(),
        .zero_o(counter_o)
    );
    /* watchdog */
    pcounter32_clkp_arstn_load #(
        .LOAD_VAL(WDT_MAX_VAL)
    ) pcnt_wdt (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b1),  // count down
        .event_i(qclk_o | wdt_o),
        .enable_i(1'b1),
        .match0_o(),
        .match1_o(),
        .zero_o(wdt_o)
    );

endmodule
