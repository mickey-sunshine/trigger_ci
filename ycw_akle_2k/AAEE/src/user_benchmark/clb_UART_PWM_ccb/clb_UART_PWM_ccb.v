//`define FULL_CCB_MODEL_FOR_SIM 1
module clb_UART_PWM_ccb #(
    parameter CLOCK_FREQ = 50000000,  // 100 MHz default
    parameter BAUD_RATE  = 115200     // 1M bps default
) (
    input wire clk_i,  // System clock
    input wire rst_ni, // Active low reset

    // UART interface
    input  wire rx_i,  // UART RX
    output wire tx_o,  // UART TX

    output wire [1:0] zero_o,  // 防止pcnt被优化
    output reg pwm_o,  // pwm output
    output wire event_o  // event output for debug

);

    // uart_top Outputs
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;
    wire [3:0] event_ccb;

    wire [31:0] match0_ref0_o, match1_ref0_o, load_val0_o;
    wire [31:0] match0_ref1_o, match1_ref1_o, load_val1_o;
    wire [31:0] match0_ref2_o, match1_ref2_o, load_val2_o;

    wire [31:0] counter0, counter1;
    reg enable0, enable1;
    reg ready0, ready1;
    reg event_match;
    reg event_match_d1;

    uart_top #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_uart_top (
        .clk     (clk_i),
        .reset_n (rst_ni),
        .rx      (rx_i),
        .tx_data (),
        .tx_start(),

        .tx     (tx_o),
        .tx_busy(),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    /* event (event is [0:3] in ccb, not [3:0])*/
    assign event_ccb[0] = 1'b0;
    assign event_ccb[1] = 1'b0;
    assign event_ccb[2] = 1'b0;
    assign event_ccb[3] = event_o;
    assign event_o = (~event_match_d1) & event_match;

    wire pcnt0_event, pcnt1_event, pcnt2_event;
    wire [5:0] ccb_pcnt_event;
    assign pcnt0_event = write_match;
    assign pcnt1_event = write_match;
    assign pcnt2_event = pcnt2_zero;
    assign ccb_pcnt_event = {pcnt0_event, 1'b0, pcnt1_event, 1'b0, pcnt2_event, 1'b0};

    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`MOV_T1, `C0, `C2}),
        .EVENT0_INST1({`MOV_T2, `C1, `C2}),
        // PCNT initial values
        .LOAD_VAL_PCNT0({32{1'b0}}),
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0({32{1'b0}}),
        .MATCH0_REF_PCNT1({32{1'b0}}),
        .MATCH0_REF_PCNT2({32'd20}),
        .MATCH1_REF_PCNT0({32{1'b0}}),
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2({32'd100})
    ) u_ccb (
        .ccb_clk_i    (clk_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (event_ccb),
        .pcnt_event_i (ccb_pcnt_event),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (counter0),
        .rdata1_i     (counter1),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(match0_ref0_o),
        .match1_ref0_o(match1_ref0_o),
        .load_val0_o  (load_val0_o),
        .match0_ref1_o(match0_ref1_o),
        .match1_ref1_o(match1_ref1_o),
        .load_val1_o  (load_val1_o),
        .match0_ref2_o(match0_ref2_o),
        .match1_ref2_o(match1_ref2_o),
        .load_val2_o  (load_val2_o)
    );

    /* match记录 */
    reg [7:0] match0, match1;  // uart收集2次8位数据, 第一次match0, 第2次match1
    reg [7:0] cnt;  // 内部计数器记到对应match时, 将pcnt的数据通过ccb进行搬运
    reg match_record;  // 记录match0时为0, match1时为1
    reg write_match;  // 两个数都记录完成时, 开始计数并改写pcnt
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            match0 <= 8'b0;
            match1 <= 8'b0;
            match_record <= 1'b0;
            write_match <= 1'b0;
        end else begin
            if (rx_done == 1'b1) begin
                if (match_record == 1'b0) begin
                    match0 <= rx_data;
                    match_record <= 1'b1;
                    write_match <= 1'b0;
                end else begin
                    match1 <= rx_data;
                    match_record <= 1'b0;
                    write_match <= 1'b1;
                end
            end else begin
                match0 <= match0;
                match1 <= match1;
                match_record <= match_record;
                write_match <= 1'b0;
            end
        end
    end

    /* 打一拍得到上升沿 */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            event_match_d1 <= 1'b0;
        end else begin
            event_match_d1 <= event_match;
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            enable0 <= 1'b0;
            enable1 <= 1'b0;
            ready0 <= 1'b0;
            ready1 <= 1'b0;
            event_match <= 1'b0;
        end else begin
            if (write_match) begin
                enable0 <= 1'b1;
                enable1 <= 1'b1;
                ready0 <= 1'b0;
                ready1 <= 1'b0;
                event_match <= 1'b0;
            end else if (ready0 == 1'b1 && ready1 == 1'b1) begin
                enable0 <= enable0;
                enable1 <= enable1;
                ready0 <= ready0;
                ready1 <= ready1;
                event_match <= 1'b1;
            end else begin
                if (cnt > match0) begin
                    enable0 <= 1'b0;
                    ready0  <= 1'b1;
                end else begin
                    enable0 <= enable0;
                    ready0  <= ready0;
                end
                if (cnt > match1) begin
                    enable1 <= 1'b0;
                    ready1  <= 1'b1;
                end else begin
                    enable1 <= enable1;
                    ready1  <= ready1;
                end
                event_match <= 1'b0;
            end
        end
    end

    /* local counter */
    // 内部额外配置一个计数器, 计数值到达匹配值时, 触发事件
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            cnt <= 8'b0;
        end else begin
            if (write_match) begin
                cnt <= 8'b0;
            end else if (enable0 || enable1) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= cnt;
            end
        end
    end



    /* counter 1 */
    // 生成match0
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_match0 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (pcnt0_event),
        .enable_i        (enable0),
        .ccb_match0_ref_i(match0_ref0_o),
        .ccb_match1_ref_i(match1_ref0_o),
        .ccb_load_val_i  (load_val0_o),

        .match0_o(),
        .match1_o(),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (counter0),
`endif
        .zero_o  (zero_o[0])
    );
    /* counter 2 */
    // 生成match1
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_match1 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (pcnt1_event),
        .enable_i        (enable1),
        .ccb_match0_ref_i(match0_ref1_o),
        .ccb_match1_ref_i(match1_ref1_o),
        .ccb_load_val_i  (load_val1_o),

        .match0_o(),
        .match1_o(),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (counter1),
`endif
        .zero_o  (zero_o[1])
    );

    wire pcnt2_match0;
    wire pcnt2_match1;
    wire pcnt2_zero;
    /* counter 3 */
    // 修改match0、match1后生成pwm
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_pwm_o (
        .clk_i           (clk_i),
        .rst_i           (rst_ni & (~pcnt2_match1)),
        .up_down_i       (1'b0),
        .event_i         (1'b0),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(match0_ref2_o),
        .ccb_match1_ref_i(match1_ref2_o),
        .ccb_load_val_i  (load_val2_o),

        .match0_o(pcnt2_match0),
        .match1_o(pcnt2_match1),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  (pcnt2_zero)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_o <= 1'b0;
        end else begin
            if (pcnt2_zero) begin
                pwm_o <= 1'b0;
            end else if (pcnt2_match0) begin
                pwm_o <= 1'b1;
            end else begin
                pwm_o <= pwm_o;
            end
        end
    end
endmodule
