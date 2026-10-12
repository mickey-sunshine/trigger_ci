module ccb_parallel_event (
    input  wire       clk_i,
    input  wire       clk_ccb_i,
    input  wire       rst_ni,
    input  wire [3:0] event_trig_i,  // 触发ccb事件
    output reg        pwm_o          // pwm_out
);

    wire ccb_1_pcnt_rst;
    wire [31:0] ccb_1_match0_ref0_o;
    wire [31:0] ccb_1_match1_ref0_o;
    wire [31:0] ccb_1_load_val0_o;
    wire [31:0] ccb_1_match0_ref1_o;
    wire [31:0] ccb_1_match1_ref1_o;
    wire [31:0] ccb_1_load_val1_o;
    wire [31:0] ccb_1_match0_ref2_o;
    wire [31:0] ccb_1_match1_ref2_o;
    wire [31:0] ccb_1_load_val2_o;
    wire [31:0] rdata0_i;
    localparam CCB_1_R0 = 32'd0;
    localparam CCB_1_R1 = 32'd0;
    localparam CCB_1_R2 = 32'd0;
    localparam CCB_1_R3 = 32'd0;
    localparam CCB_1_PCNT_0_LOAD_VAL = 32'd1;
    localparam CCB_1_PCNT_0_MATCH0_VAL = 32'd2;
    localparam CCB_1_PCNT_0_MATCH1_VAL = 32'd3;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `C0, `R0}),
        .EVENT0_INST1({`MOV, `R0, `R0}),
        .EVENT0_INST2({`MOV, `R0, `R0}),
        .EVENT0_INST3({`MOV, `R0, `R0}),
        .EVENT0_INST4({`MOV, `R0, `R0}),
        .EVENT0_INST5({`MOV, `R0, `R0}),
        .EVENT0_INST6({`MOV, `R0, `R0}),
        .EVENT0_INST7({`INTR, 6'b000001}),
        // Event1 triggered instructions
        .EVENT1_INST0({`ADD, `C0, `R1}),
        .EVENT1_INST1({`MOV, `R1, `R1}),
        .EVENT1_INST2({`MOV, `R1, `R1}),
        .EVENT1_INST3({`MOV, `R1, `R1}),
        .EVENT1_INST4({`MOV, `R1, `R1}),
        .EVENT1_INST5({`MOV, `R1, `R1}),
        .EVENT1_INST6({`MOV, `R1, `R1}),
        .EVENT1_INST7({`INTR, 6'b000010}),
        // Event2 triggered instructions
        .EVENT2_INST0({`ADD, `C0, `R2}),
        .EVENT2_INST1({`MOV, `R2, `R2}),
        .EVENT2_INST2({`MOV, `R2, `R2}),
        .EVENT2_INST3({`MOV, `R2, `R2}),
        .EVENT2_INST4({`MOV, `R2, `R2}),
        .EVENT2_INST5({`MOV, `R2, `R2}),
        .EVENT2_INST6({`MOV, `R2, `R2}),
        .EVENT2_INST7({`INTR, 6'b000100}),
        // Event3 triggered instructions
        .EVENT3_INST0({`ADD, `C0, `R3}),
        .EVENT3_INST1({`MOV, `R3, `R3}),
        .EVENT3_INST2({`MOV, `R3, `R3}),
        .EVENT3_INST3({`MOV, `R3, `R3}),
        .EVENT3_INST4({`MOV, `R3, `R3}),
        .EVENT3_INST5({`MOV, `R3, `R3}),
        .EVENT3_INST6({`MOV, `R3, `R3}),
        .EVENT3_INST7({`INTR, 6'b001000}),
        // Initial register values, R0-R3
        .R0(CCB_1_R0),
        .R1(CCB_1_R1),
        .R2(CCB_1_R2),
        .R3(CCB_1_R3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_1_PCNT_0_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_1_PCNT_0_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_1_PCNT_0_MATCH1_VAL)
    ) u_ccb_1 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (event_trig_i),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (rdata0_i),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_1_match0_ref0_o),
        .match1_ref0_o(ccb_1_match1_ref0_o),
        .load_val0_o  (ccb_1_load_val0_o),
        .match0_ref1_o(ccb_1_match0_ref1_o),
        .match1_ref1_o(ccb_1_match1_ref1_o),
        .load_val1_o  (ccb_1_load_val1_o),
        .match0_ref2_o(ccb_1_match0_ref2_o),
        .match1_ref2_o(ccb_1_match1_ref2_o),
        .load_val2_o  (ccb_1_load_val2_o)
    );

    /* 计时器 */
    /* 使C0保持1, 用于递增 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_310 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (1'b1),
        .enable_i        (1'b0),
        .ccb_match0_ref_i(ccb_1_match0_ref0_o),
        .ccb_match1_ref_i(ccb_1_match1_ref0_o),
        .ccb_load_val_i  (ccb_1_load_val0_o),

        .match0_o(pwm_o),
        .match1_o(),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (rdata0_i),
`endif
        .zero_o  ()
    );

endmodule
