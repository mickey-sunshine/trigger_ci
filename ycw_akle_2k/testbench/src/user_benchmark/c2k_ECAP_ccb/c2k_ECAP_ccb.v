module c2k_ECAP_ccb (
    input        clk_i,      // 输入时钟
    input        rst_ni,     // 输入复位信号
    input        in1_i,      // 输入1
    input        in2_i,      // 输入2
    output [3:0] event_ccb,  // 输出给HLC的事件, 引出用作dv监测
    output [1:0] counter_o   // 避免counter被优化
);

    parameter INPUT_SEL = 1'b0;  // 输入2选1, 0:输入1 1:输入2

    wire signal_in;
    wire rising_edge, falling_edge;
    reg signal_d1, signal_d2;
    // wire [3:0] event_ccb;
    reg s0, s1;

    wire [31:0] rdata0_i, rdata1_i, rdata2_i;
    wire [31:0] match0_ref0_o, match1_ref0_o, load_val0_o;
    wire [31:0] match0_ref1_o, match1_ref1_o, load_val1_o;
    wire [31:0] match0_ref2_o, match1_ref2_o, load_val2_o;
    /* boundary input */
    assign signal_in = (INPUT_SEL == 1'b0) ? in1_i : in2_i;
    assign rising_edge = (signal_d2 == 1'b0) && (signal_d1 == 1'b1);
    assign falling_edge = (signal_d2 == 1'b1) && (signal_d1 == 1'b0);
    // 检测状态边沿变化, 采用两级寄存器同步
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_d1 <= 1'b0;
            signal_d2 <= 1'b0;
        end else begin
            signal_d1 <= signal_in;
            signal_d2 <= signal_d1;
        end
    end

    /* FSM */
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            s0 = 1'b0;
            s1 = 1'b0;
        end else begin
            s0 = s0 ^ rising_edge;
            s1 = ~(s0 ^ rising_edge);
        end
    end

    /* event (event is [0:3] in ccb, not [3:0])*/
    // assign event_ccb[0] = falling_edge && s0;
    // assign event_ccb[1] = rising_edge;
    // assign event_ccb[2] = falling_edge && s1;
    // assign event_ccb[3] = 1'b0;
    assign event_ccb[0] = 1'b0;
    assign event_ccb[1] = falling_edge && s1;
    assign event_ccb[2] = rising_edge;
    assign event_ccb[3] = falling_edge && s0;

    wire pcnt0_event, pcnt1_event, pcnt2_event;
    wire [2:0] ccb_pcnt_event;
    assign pcnt0_event = rising_edge;
    assign pcnt1_event = falling_edge;
    assign pcnt2_event = 1'b0;
    assign ccb_pcnt_event = {pcnt0_event, pcnt1_event, pcnt2_event};

    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`MOV, `C0, `R0}),
        // Event1 triggered instructions
        .EVENT1_INST0({`MOV, `C1, `R1}),
        // Event2 triggered instructions
        .EVENT2_INST0({`MOV, `C0, `R2}),
        .EVENT2_INST1({`PUSH, `R0, 3'h0}),
        .EVENT2_INST2({`PUSH, `R1, 3'h0}),
        .EVENT2_INST3({`PUSH, `R2, 3'h0}),
        .EVENT2_INST4({`PUSH, `R3, 3'h0}),
        .EVENT2_INST5({`INTR, 6'h01}),
        // PCNT initial values
        .LOAD_VAL_PCNT0({32{1'b0}}),
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0({32{1'b0}}),
        .MATCH0_REF_PCNT1({32{1'b0}}),
        .MATCH0_REF_PCNT2({32{1'b0}}),
        .MATCH1_REF_PCNT0({32{1'b0}}),
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2({32{1'b0}})
    ) u_ccb (
        .ccb_clk_i    (clk_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (event_ccb),
        .pcnt_event_i (ccb_pcnt_event),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (rdata0_i),
        .rdata1_i     (rdata1_i),
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

    /* counter */
    // 内部均使用同步后的信号
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_High (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (pcnt0_event),
        .enable_i        (signal_d1),
        .ccb_match0_ref_i(match0_ref0_o),
        .ccb_match1_ref_i(match1_ref0_o),
        .ccb_load_val_i  (load_val0_o),

        .match0_o(),
        .match1_o(),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (rdata0_i),
`endif
        .zero_o  (counter_o[0])
    );
    // pcounter32_clkp_arstn_load pcnt_High (
    //     .clk_i(clk_i),
    //     .rst_i(rst_ni),
    //     .up_down_i(1'b0),
    //     .event_i(rising_edge),
    //     .enable_i(signal_d1),
    //     .match0_o(),
    //     .match1_o(),
    //     .zero_o(counter_o[0])
    // );
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_Low (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (pcnt1_event),
        .enable_i        (~signal_d1),
        .ccb_match0_ref_i(match0_ref1_o),
        .ccb_match1_ref_i(match1_ref1_o),
        .ccb_load_val_i  (load_val1_o),

        .match0_o(),
        .match1_o(),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (rdata1_i),
`endif
        .zero_o  (counter_o[1])
    );
    // pcounter32_clkp_arstn_load pcnt_Low (
    //     .clk_i(clk_i),
    //     .rst_i(rst_ni),
    //     .up_down_i(1'b0),
    //     .event_i(falling_edge),
    //     .enable_i(~signal_d1),
    //     .match0_o(),
    //     .match1_o(),
    //     .zero_o(counter_o[1])
    // );

endmodule
