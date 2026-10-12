module c2k_timer_ccb (
    input  wire       clk_i,
    input  wire       rst_ni,
    input  wire [1:0] event_trig_i,  // 触发ccb事件, 更新match值
    input  wire       counter_en_i,  // 计数器使能
    input  wire       direction_i,   // 计数器方向
    output wire       interrupt_o,   // 计数器输出中断信号
    output reg        gpio_o         // 反转一个gpio
);

    parameter LOAD_VAL = 32'd0;
    parameter MATCH0_VAL = 32'd100;
    parameter R0 = 32'd0;
    parameter R1 = 32'd20;
    parameter R2 = 32'd50;
    parameter R3 = 32'd100;
    // Timer implementation goes here
    wire match_zero;
    wire [31:0] match0_ref0_o, match1_ref0_o, load_val0_o;
    wire [3:0] event_ccb;
    wire [5:0] cbb_pcnt_event;
    assign event_ccb[0]   = event_trig_i[1];
    assign event_ccb[1]   = event_trig_i[0];
    assign event_ccb[2]   = dir_down;
    assign event_ccb[3]   = dir_up;
    assign cbb_pcnt_event = {6'b111111};
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        // 向上计数时触发, 将load设为0
        .EVENT0_INST0({`MOV, `R0, `C0}),
        // Event1 triggered instructions
        // 向下计数时触发, 将load设为R3(100)
        .EVENT1_INST0({`MOV, `R3, `C0}),
        // Event2 triggered instructions
        // 将match0设为R2的值(50)
        .EVENT2_INST0({`MOV, `R2, `R3}),
        .EVENT2_INST1({`MOV_T1, `R2, `C0}),
        // Event3 triggered instructions
        // 将match0设为R1的值(20)
        .EVENT3_INST0({`MOV, `R1, `R3}),
        .EVENT3_INST1({`MOV_T1, `R1, `C0}),
        // Initial register values, R0-R3
        .R0(R0),
        .R1(R1),
        .R2(R2),
        .R3(R3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(LOAD_VAL),
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0(MATCH0_VAL),
        .MATCH0_REF_PCNT1({32{1'b0}}),
        .MATCH0_REF_PCNT2({32{1'b0}}),
        .MATCH1_REF_PCNT0({32{1'b0}}),
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2({32{1'b0}})
    ) u_ccb (
        .ccb_clk_i    (clk_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (event_ccb),
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
        .match0_ref1_o(),
        .match1_ref1_o(),
        .load_val1_o  (),
        .match0_ref2_o(),
        .match1_ref2_o(),
        .load_val2_o  ()
    );

    reg direction_i_d1;
    wire dir_up, dir_down;
    wire pcnt_event;
    reg [8:0] event_delay;  // 延迟几拍, 在ccb写入完成后触发event
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            direction_i_d1 <= 1'b0;
            event_delay <= 8'd0;
        end else begin
            direction_i_d1 <= direction_i;
            event_delay[0] <= |(event_trig_i);
            event_delay[1] <= event_delay[0];
            event_delay[2] <= event_delay[1];
            event_delay[3] <= event_delay[2];
            event_delay[4] <= event_delay[3];
            event_delay[5] <= event_delay[4];
            event_delay[6] <= event_delay[5];
            event_delay[7] <= event_delay[6];
            event_delay[8] <= event_delay[7];
        end
    end
    assign dir_up = (~direction_i) & direction_i_d1;
    assign dir_down = direction_i & (~direction_i_d1);
    assign pcnt_event = direction_i ? (match_zero) : (match1_w);
    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) core (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (direction_i),
        // .up_down_i       (1'b0),                      // 不考虑方向变化, 仅向上计数
        .event_i         (pcnt_event || event_delay[8]),
        .enable_i        (counter_en_i),
        .ccb_match0_ref_i(match0_ref0_o),
        .ccb_match1_ref_i(match1_ref0_o),
        .ccb_load_val_i  (load_val0_o),

        .match0_o(match1_w),
        .match1_o(),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  (match_zero)
    );

    /* 计时器输出中断 */
    assign interrupt_o = match_zero;

    /* 反转一个GPIO */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            gpio_o <= 1'b0;
        end else begin
            if (match_zero) begin
                gpio_o <= ~gpio_o;
            end else begin
                gpio_o <= gpio_o;
            end
        end
    end

endmodule
