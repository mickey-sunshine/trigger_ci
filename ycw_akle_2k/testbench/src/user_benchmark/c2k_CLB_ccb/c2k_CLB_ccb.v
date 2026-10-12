module c2k_CLB_ccb (
    input clk_i,
    input rst_ni,
    input e0,
    input e1,
    output reg pwm_opening,
    output reg pwm_closing,
    output [1:0] state
);

    parameter SAMPLE_VAL = 32'd10;  // 采样输入周期
    parameter LOAD_VAL = 32'd100;  // PWM总周期
    parameter MATCH1_VAL = 32'd65;  // PWM占空比

    // 内部状态定义
    localparam OPENED = 2'b00;
    localparam CLOSING = 2'b01;
    localparam CLOSED = 2'b11;
    localparam OPENING = 2'b10;
    reg [1:0] state_d1;

    reg e0_r, e1_r;

    wire reset_counter;
    wire zero_core;
    wire sample_trigger;
    wire sample_rst;

    wire match1_o;
    wire mode0;
    // wire [31:0] q_o;
    wire [31:0] match0_ref0_o, match1_ref0_o, load_val0_o;
    wire [31:0] match0_ref1_o, match1_ref1_o, load_val1_o;
    wire [31:0] match0_ref2_o, match1_ref2_o, load_val2_o;
    /* PWM 输出逻辑 */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_opening <= 1'b0;
            pwm_closing <= 1'b0;
        end else begin
            if (state == OPENING) begin
                if (match1_o == 1'b1) begin
                    pwm_opening <= 1'b1;
                end else if (zero_core == 1'b1) begin
                    pwm_opening <= 1'b0;
                end else begin
                    pwm_opening <= pwm_opening;
                    pwm_closing <= 1'b0;
                end
            end else if (state == CLOSING) begin
                if (match1_o == 1'b1) begin
                    pwm_closing <= 1'b1;
                end else if (zero_core == 1'b1) begin
                    pwm_closing <= 1'b0;
                end else begin
                    pwm_closing <= pwm_closing;
                    pwm_opening <= 1'b0;
                end
            end else begin
                if (zero_core == 1'b1) begin
                    pwm_opening <= 1'b0;
                    pwm_closing <= 1'b0;
                end else begin
                    pwm_opening <= pwm_opening;
                    pwm_closing <= pwm_closing;
                end
            end
        end
    end

    // mode0 信号，仅在 OPENING 或 CLOSING 状态为高
    assign mode0 = (state == CLOSING || state == OPENING);

    // 检测状态边沿变化（用于重启计数器）
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) state_d1 <= OPENED;
        else state_d1 <= state;
    end


    wire pcnt0_event;
    wire [5:0] ccb_pcnt_event;
    assign pcnt0_event = zero_core || (reset_counter && mode0);
    assign cbb_pcnt_event = {pcnt0_event, 5'b00000};


    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        .LOAD_VAL_PCNT0(LOAD_VAL),  // 32d'100   32'h64
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0({32{1'b0}}),
        .MATCH0_REF_PCNT1(SAMPLE_VAL),  // 32'd10  32'hA
        .MATCH0_REF_PCNT2({32{1'b0}}),
        .MATCH1_REF_PCNT0(MATCH1_VAL),  // 32'd65  32'h41
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2({32{1'b0}})
    ) u_ccb (
        .ccb_clk_i    (clk_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (),
        .pcnt_event_i (cbb_pcnt_event),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
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


    // 状态跳变时重启计数器
    assign reset_counter = (state_d1 != state);
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) core (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b1),
        .event_i         (pcnt0_event),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(match0_ref0_o),
        .ccb_match1_ref_i(match1_ref0_o),
        .ccb_load_val_i  (load_val0_o),

        .match0_o(),
        .match1_o(match1_o),
        .zero_o  (zero_core),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     ()
`endif
    );

    // pcounter32_clkp_arstn_load #(
    //     .LOAD_VAL  (LOAD_VAL),
    //     .MATCH0_REF(32'h0),
    //     .MATCH1_REF(MATCH1_VAL)
    // ) core (
    //     .clk_i(clk_i),
    //     .rst_i(rst_ni),
    //     .up_down_i(1'b0),
    //     .event_i(zero_core || (reset_counter && mode0)),
    //     .enable_i(1'b1),
    //     .match0_o(),
    //     .match1_o(match1_o),
    //     .zero_o(zero_core)
    // );



    /* 采样计数器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(2.0)
    ) sample (
        .clk_i           (clk_i),
        .rst_i           (rst_ni && (~sample_rst)),
        .up_down_i       (1'b0),
        .event_i         (pcnt1_event),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(match0_ref1_o),
        .ccb_match1_ref_i(match1_ref1_o),
        .ccb_load_val_i  (load_val1_o),

        .match0_o(sample_rst),
        .match1_o(),
        .zero_o  (sample_trigger),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     ()
`endif
    );
    // pcounter32_clkp_arstn_load #(
    //     .LOAD_VAL  (32'h0),
    //     .MATCH0_REF(SAMPLE_VAL),
    //     .MATCH1_REF(32'h0)
    // ) sample (
    //     .clk_i(clk_i),
    //     .rst_i(rst_ni && (~sample_rst)),
    //     .up_down_i(1'b1),
    //     .event_i(),
    //     .enable_i(1'b1),
    //     .match0_o(sample_rst),
    //     .match1_o(),
    //     .zero_o(sample_trigger)
    // );
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            e0_r <= 1'b0;
            e1_r <= 1'b0;
        end else begin
            if (sample_trigger) begin
                e0_r <= e0;
                e1_r <= e1;
            end else begin
                e0_r <= e0_r;
                e1_r <= e1_r;
            end
        end
    end

    /* FSM 逻辑 */
    C2000_FSM_TC1 u_C2000_FSM_TC1 (
        .clk_i(sample_trigger),
        .rst_ni(rst_ni),
        .e0(e0_r),
        .e1(e1_r),
        .out(state)  //2bits
    );

endmodule

module C2000_FSM_TC1 (
    input            clk_i,
    input            rst_ni,
    input            e0,
    input            e1,
    output reg [1:0] out
);

    // 状态编码
    parameter OPENED = 2'b00;
    parameter CLOSING = 2'b01;
    parameter CLOSED = 2'b11;
    parameter OPENING = 2'b10;

    reg [1:0] current_state, next_state;

    // 状态寄存器
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) current_state <= OPENED;
        else current_state <= next_state;
    end

    // 状态转移逻辑
    always @(*) begin
        case (current_state)
            OPENED: begin
                next_state = (e0 == 1'b0) ? OPENED : CLOSING;
            end
            CLOSING: begin
                next_state = (e1 == 1'b0) ? CLOSING : (e0 == 1'b0) ? CLOSED : OPENING;
            end
            CLOSED: begin
                next_state = (e0 == 1'b0) ? CLOSED : OPENING;
            end
            OPENING: begin
                next_state = (e1 == 1'b0) ? OPENING : (e0 == 1'b0) ? OPENED : CLOSING;
            end
            default: next_state = OPENED;
        endcase
    end

    // 输出逻辑（Moore型，输出只与当前状态有关）
    always @(*) begin
        case (current_state)
            OPENED:  out = 2'b00;
            CLOSING: out = 2'b01;
            CLOSED:  out = 2'b11;
            OPENING: out = 2'b10;
            default: out = 2'b00;
        endcase
    end

endmodule
