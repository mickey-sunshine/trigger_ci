/* UTF-8 */
module C2000_testcase4 (
    input clk_i,  // 输入时钟
    input rst_ni,  // 输入复位信号
    input EQEP_A_i,  // EQEP_A
    input EQEP_B_i,  // EQEP_B
    input EQEP_I_i,  // EQEP_I
    output wire wdt_o,  // 定期检测信号
    output reg dir_o,  // 输出转动方向, 0 表示逆时针, 1 表示顺时针
    output wire error_o,  // 出现错误中断
    output wire counter_o  // 避免counter被优化
);

    parameter MOD_SEL_QDU = 2'b00;  // 正交解码器(QDU) 功能选择(暂时只支持00) 00:正交计数 01:方向计数 10:递增计数 11:递减计数
    parameter MOD_SEL_IN = 1'b0;  // 输入模式选择 0:QEP 1:CW/CCW
    parameter CNT_RST_MODE = 2'b00; // 计数器复位模式选择(暂时只支持00) 00:EQEP_I触发 01:计数到最大值 10:第一个索引值 11:单位超时
    parameter CNT_MAX_VAL = 32'd2000;  // 计数器最大值
    parameter WDT_MAX_VAL = 32'd1000;  // 计数器最大值
    reg dir_err;
    reg cnt_rst_event;
    assign error_o = dir_err;

    reg qclk;
    reg edge_a, edge_b;
    reg EQEP_A_d1, EQEP_B_d1;
    reg [1:0] state, state_d1;
    /* 正交解码单元(QDU) */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            qclk <= 1'b0;
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
            qclk <= edge_a | edge_b;
            if (qclk) begin
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
                    end else begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end
                end
                2'b01: begin
                    if (state_d1 == 2'b11) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b00) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end
                end
                2'b10: begin
                    if (state_d1 == 2'b00) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b11) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
                    end
                end
                2'b11: begin
                    if (state_d1 == 2'b10) begin  // clockwise
                        dir_o   <= 1'b1;
                        dir_err <= 1'b0;
                    end else if (state_d1 == 2'b01) begin  // counterclockwise
                        dir_o   <= 1'b0;
                        dir_err <= 1'b0;
                    end else begin  // error
                        dir_o   <= 1'b0;
                        dir_err <= 1'b1;
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

    wire rst_zero;
    wire rst_max;
    assign rst_zero = (dir_o) ? cnt_rst_event : 1'b0;
    assign rst_max  = (~dir_o) ? cnt_rst_event : 1'b0;
    /* counter */
    pcounter32_clkp_srstp_load #(
        .LOAD_VAL(CNT_MAX_VAL)
    ) pcnt_pos (
        .clk_i(clk_i),
        .rst_i(rst_zero | (~rst_ni)),  // when clockwise, reset to zero
        .up_down_i(dir_o),
        .event_i(rst_max),  // when conter clockwise, reset to max
        .enable_i(qclk),
        .match0_o(),
        .match1_o(),
        .zero_o(counter_o)
    );
    /* watchdog */
    pcounter32_clkp_srstn_load #(
        .LOAD_VAL(WDT_MAX_VAL)
    ) pcnt_wdt (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),  // count down
        .event_i(qclk | wdt_o),
        .enable_i(1'b1),
        .match0_o(),
        .match1_o(),
        .zero_o(wdt_o)
    );

endmodule
