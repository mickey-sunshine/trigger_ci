
module ccb_tile_ahb_access (
    input  wire        clk_i,
    input  wire        clk_ccb_i,
    input  wire        rst_ni,
    input  wire [ 5:0] event_trig_i,  // 触发ccb事件
    output wire [17:0] pwm_o          // pwm_out
);

    wire [ 2:0] ccb_1_pwm_o;
    wire [ 2:0] ccb_1_pcnt_rst;
    wire [31:0] ccb_1_match0_ref0_o;
    wire [31:0] ccb_1_match1_ref0_o;
    wire [31:0] ccb_1_load_val0_o;
    wire [31:0] ccb_1_match0_ref1_o;
    wire [31:0] ccb_1_match1_ref1_o;
    wire [31:0] ccb_1_load_val1_o;
    wire [31:0] ccb_1_match0_ref2_o;
    wire [31:0] ccb_1_match1_ref2_o;
    wire [31:0] ccb_1_load_val2_o;
    localparam CCB_1_R0 = (32'd1 * 32'd100) + 32'd0;
    localparam CCB_1_R1 = (32'd1 * 32'd100) + 32'd1;
    localparam CCB_1_R2 = (32'd1 * 32'd100) + 32'd2;
    localparam CCB_1_R3 = (32'd1 * 32'd100) + 32'd3;
    localparam CCB_1_FIFO_INIT0 = (32'd1 * 32'd100) + 32'd4;
    localparam CCB_1_FIFO_INIT1 = (32'd1 * 32'd100) + 32'd5;
    localparam CCB_1_FIFO_INIT2 = (32'd1 * 32'd100) + 32'd6;
    localparam CCB_1_FIFO_INIT3 = (32'd1 * 32'd100) + 32'd7;
    localparam CCB_1_PCNT_0_LOAD_VAL = (32'd1 * 32'd100) + 32'd10;
    localparam CCB_1_PCNT_1_LOAD_VAL = (32'd1 * 32'd100) + 32'd20;
    localparam CCB_1_PCNT_2_LOAD_VAL = (32'd1 * 32'd100) + 32'd30;
    localparam CCB_1_PCNT_0_MATCH0_VAL = (32'd1 * 32'd100) + 32'd11;
    localparam CCB_1_PCNT_1_MATCH0_VAL = (32'd1 * 32'd100) + 32'd21;
    localparam CCB_1_PCNT_2_MATCH0_VAL = (32'd1 * 32'd100) + 32'd31;
    localparam CCB_1_PCNT_0_MATCH1_VAL = (32'd1 * 32'd100) + 32'd12;
    localparam CCB_1_PCNT_1_MATCH1_VAL = (32'd1 * 32'd100) + 32'd22;
    localparam CCB_1_PCNT_2_MATCH1_VAL = (32'd1 * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `R3, `R0}),
        .EVENT0_INST1({`PUSH, `R0, 3'b000}),
        .EVENT0_INST2({`ADD, `R3, `R0}),
        .EVENT0_INST3({`PUSH, `R0, 3'b000}),
        .EVENT0_INST4({`ADD, `R3, `R0}),
        .EVENT0_INST5({`PUSH, `R0, 3'b000}),
        .EVENT0_INST6({`ADD, `R3, `R0}),
        .EVENT0_INST7({`PUSH, `R0, 3'b000}),
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
        .LOAD_VAL_PCNT1(CCB_1_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_1_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_1_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_1_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_1_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_1_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_1_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_1_PCNT_2_MATCH1_VAL)
    ) u_ccb_1 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i[0], 3'b0}),
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
        .event_i         (ccb_1_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_1_match0_ref0_o),
        .ccb_match1_ref_i(ccb_1_match1_ref0_o),
        .ccb_load_val_i  (ccb_1_load_val0_o),

        .match0_o(ccb_1_pwm_o[0]),
        .match1_o(ccb_1_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_311 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_1_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_1_match0_ref1_o),
        .ccb_match1_ref_i(ccb_1_match1_ref1_o),
        .ccb_load_val_i  (ccb_1_load_val1_o),

        .match0_o(ccb_1_pwm_o[1]),
        .match1_o(ccb_1_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_312 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_1_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_1_match0_ref2_o),
        .ccb_match1_ref_i(ccb_1_match1_ref2_o),
        .ccb_load_val_i  (ccb_1_load_val2_o),

        .match0_o(ccb_1_pwm_o[2]),
        .match1_o(ccb_1_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );


    wire [ 2:0] ccb_2_pwm_o;
    wire [ 2:0] ccb_2_pcnt_rst;
    wire [31:0] ccb_2_match0_ref0_o;
    wire [31:0] ccb_2_match1_ref0_o;
    wire [31:0] ccb_2_load_val0_o;
    wire [31:0] ccb_2_match0_ref1_o;
    wire [31:0] ccb_2_match1_ref1_o;
    wire [31:0] ccb_2_load_val1_o;
    wire [31:0] ccb_2_match0_ref2_o;
    wire [31:0] ccb_2_match1_ref2_o;
    wire [31:0] ccb_2_load_val2_o;
    localparam CCB_2_R0 = (32'd2 * 32'd100) + 32'd0;
    localparam CCB_2_R1 = (32'd2 * 32'd100) + 32'd1;
    localparam CCB_2_R2 = (32'd2 * 32'd100) + 32'd2;
    localparam CCB_2_R3 = (32'd2 * 32'd100) + 32'd3;
    localparam CCB_2_FIFO_INIT0 = (32'd2 * 32'd100) + 32'd4;
    localparam CCB_2_FIFO_INIT1 = (32'd2 * 32'd100) + 32'd5;
    localparam CCB_2_FIFO_INIT2 = (32'd2 * 32'd100) + 32'd6;
    localparam CCB_2_FIFO_INIT3 = (32'd2 * 32'd100) + 32'd7;
    localparam CCB_2_PCNT_0_LOAD_VAL = (32'd2 * 32'd100) + 32'd10;
    localparam CCB_2_PCNT_1_LOAD_VAL = (32'd2 * 32'd100) + 32'd20;
    localparam CCB_2_PCNT_2_LOAD_VAL = (32'd2 * 32'd100) + 32'd30;
    localparam CCB_2_PCNT_0_MATCH0_VAL = (32'd2 * 32'd100) + 32'd11;
    localparam CCB_2_PCNT_1_MATCH0_VAL = (32'd2 * 32'd100) + 32'd21;
    localparam CCB_2_PCNT_2_MATCH0_VAL = (32'd2 * 32'd100) + 32'd31;
    localparam CCB_2_PCNT_0_MATCH1_VAL = (32'd2 * 32'd100) + 32'd12;
    localparam CCB_2_PCNT_1_MATCH1_VAL = (32'd2 * 32'd100) + 32'd22;
    localparam CCB_2_PCNT_2_MATCH1_VAL = (32'd2 * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `R3, `R0}),
        .EVENT0_INST1({`PUSH, `R0, 3'b000}),
        .EVENT0_INST2({`ADD, `R3, `R0}),
        .EVENT0_INST3({`PUSH, `R0, 3'b000}),
        .EVENT0_INST4({`ADD, `R3, `R0}),
        .EVENT0_INST5({`PUSH, `R0, 3'b000}),
        .EVENT0_INST6({`ADD, `R3, `R0}),
        .EVENT0_INST7({`PUSH, `R0, 3'b000}),
        // Initial register values, R0-R3
        .R0(CCB_2_R0),
        .R1(CCB_2_R1),
        .R2(CCB_2_R2),
        .R3(CCB_2_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_2_FIFO_INIT0),
        .FIFO_INIT1(CCB_2_FIFO_INIT1),
        .FIFO_INIT2(CCB_2_FIFO_INIT2),
        .FIFO_INIT3(CCB_2_FIFO_INIT3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_2_PCNT_0_LOAD_VAL),
        .LOAD_VAL_PCNT1(CCB_2_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_2_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_2_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_2_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_2_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_2_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_2_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_2_PCNT_2_MATCH1_VAL)
    ) u_ccb_2 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i[1], 3'b0}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_2_match0_ref0_o),
        .match1_ref0_o(ccb_2_match1_ref0_o),
        .load_val0_o  (ccb_2_load_val0_o),
        .match0_ref1_o(ccb_2_match0_ref1_o),
        .match1_ref1_o(ccb_2_match1_ref1_o),
        .load_val1_o  (ccb_2_load_val1_o),
        .match0_ref2_o(ccb_2_match0_ref2_o),
        .match1_ref2_o(ccb_2_match1_ref2_o),
        .load_val2_o  (ccb_2_load_val2_o)
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_320 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_2_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_2_match0_ref0_o),
        .ccb_match1_ref_i(ccb_2_match1_ref0_o),
        .ccb_load_val_i  (ccb_2_load_val0_o),

        .match0_o(ccb_2_pwm_o[0]),
        .match1_o(ccb_2_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_321 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_2_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_2_match0_ref1_o),
        .ccb_match1_ref_i(ccb_2_match1_ref1_o),
        .ccb_load_val_i  (ccb_2_load_val1_o),

        .match0_o(ccb_2_pwm_o[1]),
        .match1_o(ccb_2_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_322 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_2_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_2_match0_ref2_o),
        .ccb_match1_ref_i(ccb_2_match1_ref2_o),
        .ccb_load_val_i  (ccb_2_load_val2_o),

        .match0_o(ccb_2_pwm_o[2]),
        .match1_o(ccb_2_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );


    wire [ 2:0] ccb_3_pwm_o;
    wire [ 2:0] ccb_3_pcnt_rst;
    wire [31:0] ccb_3_match0_ref0_o;
    wire [31:0] ccb_3_match1_ref0_o;
    wire [31:0] ccb_3_load_val0_o;
    wire [31:0] ccb_3_match0_ref1_o;
    wire [31:0] ccb_3_match1_ref1_o;
    wire [31:0] ccb_3_load_val1_o;
    wire [31:0] ccb_3_match0_ref2_o;
    wire [31:0] ccb_3_match1_ref2_o;
    wire [31:0] ccb_3_load_val2_o;
    localparam CCB_3_R0 = (32'd3 * 32'd100) + 32'd0;
    localparam CCB_3_R1 = (32'd3 * 32'd100) + 32'd1;
    localparam CCB_3_R2 = (32'd3 * 32'd100) + 32'd2;
    localparam CCB_3_R3 = (32'd3 * 32'd100) + 32'd3;
    localparam CCB_3_FIFO_INIT0 = (32'd3 * 32'd100) + 32'd4;
    localparam CCB_3_FIFO_INIT1 = (32'd3 * 32'd100) + 32'd5;
    localparam CCB_3_FIFO_INIT2 = (32'd3 * 32'd100) + 32'd6;
    localparam CCB_3_FIFO_INIT3 = (32'd3 * 32'd100) + 32'd7;
    localparam CCB_3_PCNT_0_LOAD_VAL = (32'd3 * 32'd100) + 32'd10;
    localparam CCB_3_PCNT_1_LOAD_VAL = (32'd3 * 32'd100) + 32'd20;
    localparam CCB_3_PCNT_2_LOAD_VAL = (32'd3 * 32'd100) + 32'd30;
    localparam CCB_3_PCNT_0_MATCH0_VAL = (32'd3 * 32'd100) + 32'd11;
    localparam CCB_3_PCNT_1_MATCH0_VAL = (32'd3 * 32'd100) + 32'd21;
    localparam CCB_3_PCNT_2_MATCH0_VAL = (32'd3 * 32'd100) + 32'd31;
    localparam CCB_3_PCNT_0_MATCH1_VAL = (32'd3 * 32'd100) + 32'd12;
    localparam CCB_3_PCNT_1_MATCH1_VAL = (32'd3 * 32'd100) + 32'd22;
    localparam CCB_3_PCNT_2_MATCH1_VAL = (32'd3 * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(3.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `R3, `R0}),
        .EVENT0_INST1({`PUSH, `R0, 3'b000}),
        .EVENT0_INST2({`ADD, `R3, `R0}),
        .EVENT0_INST3({`PUSH, `R0, 3'b000}),
        .EVENT0_INST4({`ADD, `R3, `R0}),
        .EVENT0_INST5({`PUSH, `R0, 3'b000}),
        .EVENT0_INST6({`ADD, `R3, `R0}),
        .EVENT0_INST7({`PUSH, `R0, 3'b000}),
        // Initial register values, R0-R3
        .R0(CCB_3_R0),
        .R1(CCB_3_R1),
        .R2(CCB_3_R2),
        .R3(CCB_3_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_3_FIFO_INIT0),
        .FIFO_INIT1(CCB_3_FIFO_INIT1),
        .FIFO_INIT2(CCB_3_FIFO_INIT2),
        .FIFO_INIT3(CCB_3_FIFO_INIT3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_3_PCNT_0_LOAD_VAL),
        .LOAD_VAL_PCNT1(CCB_3_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_3_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_3_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_3_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_3_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_3_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_3_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_3_PCNT_2_MATCH1_VAL)
    ) u_ccb_3 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i[2], 3'b0}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_3_match0_ref0_o),
        .match1_ref0_o(ccb_3_match1_ref0_o),
        .load_val0_o  (ccb_3_load_val0_o),
        .match0_ref1_o(ccb_3_match0_ref1_o),
        .match1_ref1_o(ccb_3_match1_ref1_o),
        .load_val1_o  (ccb_3_load_val1_o),
        .match0_ref2_o(ccb_3_match0_ref2_o),
        .match1_ref2_o(ccb_3_match1_ref2_o),
        .load_val2_o  (ccb_3_load_val2_o)
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(3.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_330 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_3_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_3_match0_ref0_o),
        .ccb_match1_ref_i(ccb_3_match1_ref0_o),
        .ccb_load_val_i  (ccb_3_load_val0_o),

        .match0_o(ccb_3_pwm_o[0]),
        .match1_o(ccb_3_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(3.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_331 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_3_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_3_match0_ref1_o),
        .ccb_match1_ref_i(ccb_3_match1_ref1_o),
        .ccb_load_val_i  (ccb_3_load_val1_o),

        .match0_o(ccb_3_pwm_o[1]),
        .match1_o(ccb_3_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(3.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_332 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_3_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_3_match0_ref2_o),
        .ccb_match1_ref_i(ccb_3_match1_ref2_o),
        .ccb_load_val_i  (ccb_3_load_val2_o),

        .match0_o(ccb_3_pwm_o[2]),
        .match1_o(ccb_3_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );


    wire [ 2:0] ccb_4_pwm_o;
    wire [ 2:0] ccb_4_pcnt_rst;
    wire [31:0] ccb_4_match0_ref0_o;
    wire [31:0] ccb_4_match1_ref0_o;
    wire [31:0] ccb_4_load_val0_o;
    wire [31:0] ccb_4_match0_ref1_o;
    wire [31:0] ccb_4_match1_ref1_o;
    wire [31:0] ccb_4_load_val1_o;
    wire [31:0] ccb_4_match0_ref2_o;
    wire [31:0] ccb_4_match1_ref2_o;
    wire [31:0] ccb_4_load_val2_o;
    localparam CCB_4_R0 = (32'd4 * 32'd100) + 32'd0;
    localparam CCB_4_R1 = (32'd4 * 32'd100) + 32'd1;
    localparam CCB_4_R2 = (32'd4 * 32'd100) + 32'd2;
    localparam CCB_4_R3 = (32'd4 * 32'd100) + 32'd3;
    localparam CCB_4_FIFO_INIT0 = (32'd4 * 32'd100) + 32'd4;
    localparam CCB_4_FIFO_INIT1 = (32'd4 * 32'd100) + 32'd5;
    localparam CCB_4_FIFO_INIT2 = (32'd4 * 32'd100) + 32'd6;
    localparam CCB_4_FIFO_INIT3 = (32'd4 * 32'd100) + 32'd7;
    localparam CCB_4_PCNT_0_LOAD_VAL = (32'd4 * 32'd100) + 32'd10;
    localparam CCB_4_PCNT_1_LOAD_VAL = (32'd4 * 32'd100) + 32'd20;
    localparam CCB_4_PCNT_2_LOAD_VAL = (32'd4 * 32'd100) + 32'd30;
    localparam CCB_4_PCNT_0_MATCH0_VAL = (32'd4 * 32'd100) + 32'd11;
    localparam CCB_4_PCNT_1_MATCH0_VAL = (32'd4 * 32'd100) + 32'd21;
    localparam CCB_4_PCNT_2_MATCH0_VAL = (32'd4 * 32'd100) + 32'd31;
    localparam CCB_4_PCNT_0_MATCH1_VAL = (32'd4 * 32'd100) + 32'd12;
    localparam CCB_4_PCNT_1_MATCH1_VAL = (32'd4 * 32'd100) + 32'd22;
    localparam CCB_4_PCNT_2_MATCH1_VAL = (32'd4 * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(4.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `R3, `R0}),
        .EVENT0_INST1({`PUSH, `R0, 3'b000}),
        .EVENT0_INST2({`ADD, `R3, `R0}),
        .EVENT0_INST3({`PUSH, `R0, 3'b000}),
        .EVENT0_INST4({`ADD, `R3, `R0}),
        .EVENT0_INST5({`PUSH, `R0, 3'b000}),
        .EVENT0_INST6({`ADD, `R3, `R0}),
        .EVENT0_INST7({`PUSH, `R0, 3'b000}),
        // Initial register values, R0-R3
        .R0(CCB_4_R0),
        .R1(CCB_4_R1),
        .R2(CCB_4_R2),
        .R3(CCB_4_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_4_FIFO_INIT0),
        .FIFO_INIT1(CCB_4_FIFO_INIT1),
        .FIFO_INIT2(CCB_4_FIFO_INIT2),
        .FIFO_INIT3(CCB_4_FIFO_INIT3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_4_PCNT_0_LOAD_VAL),
        .LOAD_VAL_PCNT1(CCB_4_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_4_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_4_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_4_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_4_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_4_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_4_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_4_PCNT_2_MATCH1_VAL)
    ) u_ccb_4 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i[3], 3'b0}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_4_match0_ref0_o),
        .match1_ref0_o(ccb_4_match1_ref0_o),
        .load_val0_o  (ccb_4_load_val0_o),
        .match0_ref1_o(ccb_4_match0_ref1_o),
        .match1_ref1_o(ccb_4_match1_ref1_o),
        .load_val1_o  (ccb_4_load_val1_o),
        .match0_ref2_o(ccb_4_match0_ref2_o),
        .match1_ref2_o(ccb_4_match1_ref2_o),
        .load_val2_o  (ccb_4_load_val2_o)
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(4.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_340 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_4_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_4_match0_ref0_o),
        .ccb_match1_ref_i(ccb_4_match1_ref0_o),
        .ccb_load_val_i  (ccb_4_load_val0_o),

        .match0_o(ccb_4_pwm_o[0]),
        .match1_o(ccb_4_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(4.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_341 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_4_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_4_match0_ref1_o),
        .ccb_match1_ref_i(ccb_4_match1_ref1_o),
        .ccb_load_val_i  (ccb_4_load_val1_o),

        .match0_o(ccb_4_pwm_o[1]),
        .match1_o(ccb_4_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(4.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_342 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_4_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_4_match0_ref2_o),
        .ccb_match1_ref_i(ccb_4_match1_ref2_o),
        .ccb_load_val_i  (ccb_4_load_val2_o),

        .match0_o(ccb_4_pwm_o[2]),
        .match1_o(ccb_4_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );


    wire [ 2:0] ccb_5_pwm_o;
    wire [ 2:0] ccb_5_pcnt_rst;
    wire [31:0] ccb_5_match0_ref0_o;
    wire [31:0] ccb_5_match1_ref0_o;
    wire [31:0] ccb_5_load_val0_o;
    wire [31:0] ccb_5_match0_ref1_o;
    wire [31:0] ccb_5_match1_ref1_o;
    wire [31:0] ccb_5_load_val1_o;
    wire [31:0] ccb_5_match0_ref2_o;
    wire [31:0] ccb_5_match1_ref2_o;
    wire [31:0] ccb_5_load_val2_o;
    localparam CCB_5_R0 = (32'd5 * 32'd100) + 32'd0;
    localparam CCB_5_R1 = (32'd5 * 32'd100) + 32'd1;
    localparam CCB_5_R2 = (32'd5 * 32'd100) + 32'd2;
    localparam CCB_5_R3 = (32'd5 * 32'd100) + 32'd3;
    localparam CCB_5_FIFO_INIT0 = (32'd5 * 32'd100) + 32'd4;
    localparam CCB_5_FIFO_INIT1 = (32'd5 * 32'd100) + 32'd5;
    localparam CCB_5_FIFO_INIT2 = (32'd5 * 32'd100) + 32'd6;
    localparam CCB_5_FIFO_INIT3 = (32'd5 * 32'd100) + 32'd7;
    localparam CCB_5_PCNT_0_LOAD_VAL = (32'd5 * 32'd100) + 32'd10;
    localparam CCB_5_PCNT_1_LOAD_VAL = (32'd5 * 32'd100) + 32'd20;
    localparam CCB_5_PCNT_2_LOAD_VAL = (32'd5 * 32'd100) + 32'd30;
    localparam CCB_5_PCNT_0_MATCH0_VAL = (32'd5 * 32'd100) + 32'd11;
    localparam CCB_5_PCNT_1_MATCH0_VAL = (32'd5 * 32'd100) + 32'd21;
    localparam CCB_5_PCNT_2_MATCH0_VAL = (32'd5 * 32'd100) + 32'd31;
    localparam CCB_5_PCNT_0_MATCH1_VAL = (32'd5 * 32'd100) + 32'd12;
    localparam CCB_5_PCNT_1_MATCH1_VAL = (32'd5 * 32'd100) + 32'd22;
    localparam CCB_5_PCNT_2_MATCH1_VAL = (32'd5 * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(5.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `R3, `R0}),
        .EVENT0_INST1({`PUSH, `R0, 3'b000}),
        .EVENT0_INST2({`ADD, `R3, `R0}),
        .EVENT0_INST3({`PUSH, `R0, 3'b000}),
        .EVENT0_INST4({`ADD, `R3, `R0}),
        .EVENT0_INST5({`PUSH, `R0, 3'b000}),
        .EVENT0_INST6({`ADD, `R3, `R0}),
        .EVENT0_INST7({`PUSH, `R0, 3'b000}),
        // Initial register values, R0-R3
        .R0(CCB_5_R0),
        .R1(CCB_5_R1),
        .R2(CCB_5_R2),
        .R3(CCB_5_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_5_FIFO_INIT0),
        .FIFO_INIT1(CCB_5_FIFO_INIT1),
        .FIFO_INIT2(CCB_5_FIFO_INIT2),
        .FIFO_INIT3(CCB_5_FIFO_INIT3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_5_PCNT_0_LOAD_VAL),
        .LOAD_VAL_PCNT1(CCB_5_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_5_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_5_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_5_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_5_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_5_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_5_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_5_PCNT_2_MATCH1_VAL)
    ) u_ccb_5 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i[4], 3'b0}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_5_match0_ref0_o),
        .match1_ref0_o(ccb_5_match1_ref0_o),
        .load_val0_o  (ccb_5_load_val0_o),
        .match0_ref1_o(ccb_5_match0_ref1_o),
        .match1_ref1_o(ccb_5_match1_ref1_o),
        .load_val1_o  (ccb_5_load_val1_o),
        .match0_ref2_o(ccb_5_match0_ref2_o),
        .match1_ref2_o(ccb_5_match1_ref2_o),
        .load_val2_o  (ccb_5_load_val2_o)
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(5.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_350 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_5_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_5_match0_ref0_o),
        .ccb_match1_ref_i(ccb_5_match1_ref0_o),
        .ccb_load_val_i  (ccb_5_load_val0_o),

        .match0_o(ccb_5_pwm_o[0]),
        .match1_o(ccb_5_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(5.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_351 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_5_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_5_match0_ref1_o),
        .ccb_match1_ref_i(ccb_5_match1_ref1_o),
        .ccb_load_val_i  (ccb_5_load_val1_o),

        .match0_o(ccb_5_pwm_o[1]),
        .match1_o(ccb_5_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(5.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_352 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_5_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_5_match0_ref2_o),
        .ccb_match1_ref_i(ccb_5_match1_ref2_o),
        .ccb_load_val_i  (ccb_5_load_val2_o),

        .match0_o(ccb_5_pwm_o[2]),
        .match1_o(ccb_5_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );


    wire [ 2:0] ccb_6_pwm_o;
    wire [ 2:0] ccb_6_pcnt_rst;
    wire [31:0] ccb_6_match0_ref0_o;
    wire [31:0] ccb_6_match1_ref0_o;
    wire [31:0] ccb_6_load_val0_o;
    wire [31:0] ccb_6_match0_ref1_o;
    wire [31:0] ccb_6_match1_ref1_o;
    wire [31:0] ccb_6_load_val1_o;
    wire [31:0] ccb_6_match0_ref2_o;
    wire [31:0] ccb_6_match1_ref2_o;
    wire [31:0] ccb_6_load_val2_o;
    localparam CCB_6_R0 = (32'd6 * 32'd100) + 32'd0;
    localparam CCB_6_R1 = (32'd6 * 32'd100) + 32'd1;
    localparam CCB_6_R2 = (32'd6 * 32'd100) + 32'd2;
    localparam CCB_6_R3 = (32'd6 * 32'd100) + 32'd3;
    localparam CCB_6_FIFO_INIT0 = (32'd6 * 32'd100) + 32'd4;
    localparam CCB_6_FIFO_INIT1 = (32'd6 * 32'd100) + 32'd5;
    localparam CCB_6_FIFO_INIT2 = (32'd6 * 32'd100) + 32'd6;
    localparam CCB_6_FIFO_INIT3 = (32'd6 * 32'd100) + 32'd7;
    localparam CCB_6_PCNT_0_LOAD_VAL = (32'd6 * 32'd100) + 32'd10;
    localparam CCB_6_PCNT_1_LOAD_VAL = (32'd6 * 32'd100) + 32'd20;
    localparam CCB_6_PCNT_2_LOAD_VAL = (32'd6 * 32'd100) + 32'd30;
    localparam CCB_6_PCNT_0_MATCH0_VAL = (32'd6 * 32'd100) + 32'd11;
    localparam CCB_6_PCNT_1_MATCH0_VAL = (32'd6 * 32'd100) + 32'd21;
    localparam CCB_6_PCNT_2_MATCH0_VAL = (32'd6 * 32'd100) + 32'd31;
    localparam CCB_6_PCNT_0_MATCH1_VAL = (32'd6 * 32'd100) + 32'd12;
    localparam CCB_6_PCNT_1_MATCH1_VAL = (32'd6 * 32'd100) + 32'd22;
    localparam CCB_6_PCNT_2_MATCH1_VAL = (32'd6 * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(6.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`ADD, `R3, `R0}),
        .EVENT0_INST1({`PUSH, `R0, 3'b000}),
        .EVENT0_INST2({`ADD, `R3, `R0}),
        .EVENT0_INST3({`PUSH, `R0, 3'b000}),
        .EVENT0_INST4({`ADD, `R3, `R0}),
        .EVENT0_INST5({`PUSH, `R0, 3'b000}),
        .EVENT0_INST6({`ADD, `R3, `R0}),
        .EVENT0_INST7({`PUSH, `R0, 3'b000}),
        // Initial register values, R0-R3
        .R0(CCB_6_R0),
        .R1(CCB_6_R1),
        .R2(CCB_6_R2),
        .R3(CCB_6_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_6_FIFO_INIT0),
        .FIFO_INIT1(CCB_6_FIFO_INIT1),
        .FIFO_INIT2(CCB_6_FIFO_INIT2),
        .FIFO_INIT3(CCB_6_FIFO_INIT3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_6_PCNT_0_LOAD_VAL),
        .LOAD_VAL_PCNT1(CCB_6_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_6_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_6_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_6_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_6_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_6_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_6_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_6_PCNT_2_MATCH1_VAL)
    ) u_ccb_6 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i[5], 3'b0}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_6_match0_ref0_o),
        .match1_ref0_o(ccb_6_match1_ref0_o),
        .load_val0_o  (ccb_6_load_val0_o),
        .match0_ref1_o(ccb_6_match0_ref1_o),
        .match1_ref1_o(ccb_6_match1_ref1_o),
        .load_val1_o  (ccb_6_load_val1_o),
        .match0_ref2_o(ccb_6_match0_ref2_o),
        .match1_ref2_o(ccb_6_match1_ref2_o),
        .load_val2_o  (ccb_6_load_val2_o)
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(6.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_360 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_6_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_6_match0_ref0_o),
        .ccb_match1_ref_i(ccb_6_match1_ref0_o),
        .ccb_load_val_i  (ccb_6_load_val0_o),

        .match0_o(ccb_6_pwm_o[0]),
        .match1_o(ccb_6_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(6.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_361 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_6_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_6_match0_ref1_o),
        .ccb_match1_ref_i(ccb_6_match1_ref1_o),
        .ccb_load_val_i  (ccb_6_load_val1_o),

        .match0_o(ccb_6_pwm_o[1]),
        .match1_o(ccb_6_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(6.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_362 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_6_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_6_match0_ref2_o),
        .ccb_match1_ref_i(ccb_6_match1_ref2_o),
        .ccb_load_val_i  (ccb_6_load_val2_o),

        .match0_o(ccb_6_pwm_o[2]),
        .match1_o(ccb_6_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    assign pwm_o = {ccb_1_pwm_o, ccb_2_pwm_o, ccb_3_pwm_o, ccb_4_pwm_o, ccb_5_pwm_o, ccb_6_pwm_o};
endmodule
