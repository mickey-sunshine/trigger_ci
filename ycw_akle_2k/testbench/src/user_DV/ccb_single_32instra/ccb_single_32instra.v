module ccb_single_32instra (
    input  wire       clk_i,
    input  wire       clk_ccb_i,
    input  wire       rst_ni,
    input  wire [3:0] event_trig_i,              // 触发ccb事件
    output wire       pcnt_event_trig_slow,
    output wire       pcnt_internal_event_trig,
    output reg        pwm_o                      // pwm_out
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
    wire match_0;
    reg [3:0] event_trig_r_last;
    reg pcnt_event_trig;
    reg [2:0] pcnt_event_trig_r;
    // wire pcnt_event_trig_slow;

    localparam CCB_1_R0 = 32'd00;
    localparam CCB_1_R1 = 32'd50;
    localparam CCB_1_R2 = 32'd100;
    localparam CCB_1_R3 = 32'd150;
    localparam CCB_1_FIFO_INIT0 = 32'd10;
    localparam CCB_1_FIFO_INIT1 = 32'd20;
    localparam CCB_1_FIFO_INIT2 = 32'd30;
    localparam CCB_1_FIFO_INIT3 = 32'd40;
    localparam CCB_1_PCNT_0_LOAD_VAL = 32'd0;
    localparam CCB_1_PCNT_0_MATCH0_VAL = 32'd25;
    localparam CCB_1_PCNT_0_MATCH1_VAL = 32'd150;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`PULL, 3'b000, `R0}),
        .EVENT0_INST1({`ADD, `R0, `R0}),
        .EVENT0_INST2({`MOV, `R0, `R0}),
        .EVENT0_INST3({`MOV_T1, `R0, `C0}),
        .EVENT0_INST4({`ADD, `R0, `R0}),
        .EVENT0_INST5({`MOV, `R0, `R0}),
        .EVENT0_INST6({`MOV_T2, `R0, `C0}),
        .EVENT0_INST7({`INTR, 6'b000001}),
        // Event1 triggered instructions
        .EVENT1_INST0({`ADD, `R0, `R0}),
        .EVENT1_INST1({`MOV, `R1, `R0}),
        .EVENT1_INST2({`ADD, `R0, `R0}),
        .EVENT1_INST3({`MOV_T1, `R0, `C0}),
        .EVENT1_INST4({`ADD, `R0, `R0}),
        .EVENT1_INST5({`MOV, `R0, `R0}),
        .EVENT1_INST6({`MOV_T2, `R0, `C0}),
        .EVENT1_INST7({`INTR, 6'b000010}),
        // Event2 triggered instructions
        .EVENT2_INST0({`SUB, `R0, `R0}),
        .EVENT2_INST1({`MOV, `R2, `R0}),
        .EVENT2_INST2({`ADD, `R0, `R0}),
        .EVENT2_INST3({`MOV_T1, `R0, `C0}),
        .EVENT2_INST4({`ADD, `R0, `R0}),
        .EVENT2_INST5({`MOV, `R0, `R0}),
        .EVENT2_INST6({`MOV_T2, `R0, `C0}),
        .EVENT2_INST7({`INTR, 6'b000100}),
        // Event3 triggered instructions
        .EVENT3_INST0({`MOV, `R3, `R0}),
        .EVENT3_INST1({`ADD, `R0, `R0}),
        .EVENT3_INST2({`MOV, `R0, `R0}),
        .EVENT3_INST3({`MOV_T1, `R0, `C0}),
        .EVENT3_INST4({`ADD, `R0, `R0}),
        .EVENT3_INST5({`MOV, `R0, `R0}),
        .EVENT3_INST6({`MOV_T2, `R0, `C0}),
        .EVENT3_INST7({`INTR, 6'b001000}),
        // Initial register values, R0-R3
        .R0(CCB_1_R0),
        .R1(CCB_1_R1),
        .R2(CCB_1_R2),
        .R3(CCB_1_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_1_FIFO_INIT0),
        .FIFO_INIT1(CCB_1_FIFO_INIT1),
        .FIFO_INIT2(CCB_1_FIFO_INIT2),
        .FIFO_INIT3(CCB_1_FIFO_INIT3),
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
        .event_i         (pcnt_internal_event_trig),
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

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pcnt_event_trig_r <= 3'b0;
        end else begin
            pcnt_event_trig_r <= {pcnt_event_trig_r[1:0], pcnt_event_trig};
        end
    end
    assign pcnt_event_trig_slow = (|(pcnt_event_trig_r)) || pcnt_event_trig;
    assign pcnt_internal_event_trig = ccb_1_pcnt_rst || pcnt_event_trig_slow;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_o <= 1'b0;
        end else begin
            if (match_0 || ccb_1_pcnt_rst) begin
                pwm_o = ~pwm_o;
            end else begin
                pwm_o <= pwm_o;
            end
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            event_trig_r_last <= 4'b0;
            pcnt_event_trig   <= 1'b0;
        end else begin
            if (event_trig_i != event_trig_r_last) begin
                pcnt_event_trig   <= 1'b1;
                event_trig_r_last <= event_trig_i;
            end else begin
                pcnt_event_trig   <= 1'b0;
                event_trig_r_last <= event_trig_i;
            end
        end
    end

endmodule
