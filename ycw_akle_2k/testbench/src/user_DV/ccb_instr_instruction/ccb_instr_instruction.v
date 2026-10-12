
module ccb_instr_instruction (
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
    localparam CCB_1_R2 = 32'd30;
    localparam CCB_1_FIFO_INIT0 = 32'd10;
    localparam CCB_1_PCNT_0_LOAD_VAL = 32'd0;
    localparam CCB_1_PCNT_0_MATCH0_VAL = 32'd25;
    localparam CCB_1_PCNT_0_MATCH1_VAL = 32'd150;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`PULL, 3'b000, `R2}),
        .EVENT0_INST1({`INTR, 6'b000001}),
        // Event1 triggered instructions
        .EVENT1_INST0({`PUSH, `R2, 3'b000}),
        .EVENT1_INST1({`INTR, 6'b000010}),
        // Event2 triggered instructions
        .EVENT2_INST0({`INTR, 6'b001100}),
        .EVENT2_INST1({`INTR, 6'b011000}),
        .EVENT2_INST2({`INTR, 6'b111000}),
        // Initial register values, R0-R3
        .R2(CCB_1_R2),
        // FIFO initial values
        .FIFO_INIT0(32'hb),
        .FIFO_INIT1(32'ha),
        .FIFO_INIT2(32'hd),
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
        .rdata0_i     (32'b0),
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
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_310 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_1_pcnt_rst),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_1_match0_ref0_o),
        .ccb_match1_ref_i(ccb_1_match1_ref0_o),
        .ccb_load_val_i  (ccb_1_load_val0_o),

        .match0_o(match_0),
        .match1_o(ccb_1_pcnt_rst),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );
    wire match_0;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_o <= 1'b0;
        end else begin
            if (match_0) begin
                pwm_o = ~pwm_o;
            end else begin
                pwm_o <= pwm_o;
            end
        end
    end
endmodule
