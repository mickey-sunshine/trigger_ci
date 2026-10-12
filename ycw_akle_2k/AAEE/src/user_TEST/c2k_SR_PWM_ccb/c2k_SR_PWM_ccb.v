module c2k_SR_PWM_ccb (
    input        clk_i,         // To U_FCB_APBS of FCB_APBS.v
    input        rst_ni,        // To U_FCB_APBS of FCB_APBS.v
    input        epwm_1a_i,
    input        epwm_1b_i,
    input  [3:0] ccb_event0_i,
    input  [3:0] ccb_event1_i,
    output       EPWM_2A_o,
    output       EPWM_2B_o
);

    wire rst_pulse;

    reg int_rstn, int_rstn_1;

    wire pcnt0_match0_w;
    wire pcnt0_match1_w;
    wire pcnt1_match0_w;
    wire pcnt1_match1_w;
    wire pcnt2_match0_w;
    wire pcnt2_match1_w;
    wire pcnt3_match0_w;
    wire pcnt3_match1_w;

    wire pcnt0_zero;
    wire pcnt1_zero;
    wire pcnt2_zero;
    wire pcnt3_zero;

    wire trig_signal0;
    wire trig_signal1;

    wire epwm_1a_n;
    wire epwm_1a_p;
    wire epwm_1b_n;
    wire epwm_1b_p;

    wire epwm_2a;
    wire epwm_2b;

    wire [0:31] rdata0_i;
    wire [0:31] rdata1_i;
    wire [0:31] rdata2_i;
    wire [0:31] rdata3_i;
    wire [0:31] rdata4_i;
    wire [0:31] rdata5_i;

    wire [0:31] match0_ref0_o;
    wire [0:31] match1_ref0_o;
    wire [0:31] load_val0_o;
    wire [0:31] match0_ref1_o;
    wire [0:31] match1_ref1_o;
    wire [0:31] load_val1_o;
    wire [0:31] match0_ref2_o;
    wire [0:31] match1_ref2_o;
    wire [0:31] load_val2_o;
    wire [0:31] match0_ref3_o;
    wire [0:31] match1_ref3_o;
    wire [0:31] load_val3_o;
    wire [0:31] match0_ref4_o;
    wire [0:31] match1_ref4_o;
    wire [0:31] load_val4_o;
    wire [0:31] match0_ref5_o;
    wire [0:31] match1_ref5_o;
    wire [0:31] load_val5_o;
    // pull FIFO initial value
    //assign fifo_mem  = {32'd250, 32'd275, 32'd225, 32'd260};

    // output pwm
    assign EPWM_2A_o = epwm_2a;
    assign EPWM_2B_o = ~epwm_2b;

    // internal reset logic
    always @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            int_rstn   <= 1'b0;
            int_rstn_1 <= 1'b0;
        end else begin
            int_rstn   <= 1'b1;
            int_rstn_1 <= int_rstn;
        end
    end

    /*-----------------------------------------------------------
                        user logic
    -----------------------------------------------------------*/
    assign trig_signal0 = pcnt0_match0_w || pcnt2_match0_w; //pcnt0_match0_w[0] || pcnt1_match0_w[0];
    assign trig_signal1 = pcnt1_match0_w || pcnt3_match0_w; //pcnt0_match0_w[1] || pcnt1_match0_w[1];

    sr_fsm epwm_1a_fsm_inst (
        .clk(clk_i),
        .rst_n(rst_ni),
        .E0(epwm_1a_p),
        .E1(trig_signal0),
        .S0(epwm_2a)
    );

    sr_fsm epwm_1b_fsm_inst (
        .clk(clk_i),
        .rst_n(rst_ni),
        .E0(epwm_1b_p),
        .E1(trig_signal1),
        .S0(epwm_2b)
    );

    /*-----------------------------------------------------------
                        user logic
    -----------------------------------------------------------*/
    ccb #(
        .FPGA_LOC_X      (3.0),
        .FPGA_LOC_Y      (1.0),
        .FPGA_LOC_Z      (0.0),
        .EVENT0_INST0    ({`PULL, `R0, `R0}),    // pull fifo to R0
        .EVENT0_INST1    ({`MOV_T1, `R0, `C0}),  // copy R0 to pcnt0 ref0
        .EVENT0_INST2    ({`MOV_T1, `R0, `C1}),  // copy R0 to pcnt1 ref0
        .FIFO_INIT0      (32'd250),
        .FIFO_INIT1      (32'd275),
        .FIFO_INIT2      (32'd225),
        .FIFO_INIT3      (32'd260),
        .LOAD_VAL_PCNT0  (32'b0),
        .LOAD_VAL_PCNT1  (32'b0),
        .LOAD_VAL_PCNT2  (32'b0),
        .MATCH0_REF_PCNT0(32'b0),
        .MATCH0_REF_PCNT1(32'b0),
        .MATCH0_REF_PCNT2(32'b0),
        .MATCH1_REF_PCNT0(32'b0),
        .MATCH1_REF_PCNT1(32'b0),
        .MATCH1_REF_PCNT2(32'b0)
    ) u_ccb0 (
        .ccb_event_i(ccb_event0_i),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i   (rdata0_i),
        .rdata1_i   (rdata1_i),
        .rdata2_i   (rdata2_i),
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


    //----------- instances of sub modules ----------------

    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt0 (
        .clk_i(clk_i),
        .rst_i(rst_ni & (!rst_pulse)),
        .up_down_i(1'b1),
        .event_i(epwm_1a_p),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref0_o),  //(32'd250),
        .ccb_match1_ref_i(match1_ref0_o),  //(32'd0),
        .ccb_load_val_i(load_val0_o),  //(32'd0),
        .match0_o(pcnt0_match0_w),
        .match1_o(pcnt0_match1_w),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(rdata0_i),
`endif
        .zero_o(pcnt0_zero)
    );

    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt1 (
        .clk_i(clk_i),
        .rst_i(rst_ni & (!rst_pulse)),
        .up_down_i(1'b1),
        .event_i(epwm_1b_p),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref1_o),  //(32'd250),
        .ccb_match1_ref_i(match1_ref1_o),  //(32'd0),
        .ccb_load_val_i(load_val1_o),  //(32'd0),
        .match0_o(pcnt1_match0_w),
        .match1_o(pcnt1_match1_w),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(rdata1_i),
`endif
        .zero_o(pcnt1_zero)
    );

    ccb #(
        .FPGA_LOC_X      (3.0),
        .FPGA_LOC_Y      (2.0),
        .FPGA_LOC_Z      (0.0),
        .LOAD_VAL_PCNT0  (32'b0),
        .LOAD_VAL_PCNT1  (32'b0),
        .LOAD_VAL_PCNT2  (32'b0),
        .MATCH0_REF_PCNT0(32'b10),
        .MATCH0_REF_PCNT1(32'b10),
        .MATCH0_REF_PCNT2(32'b0),
        .MATCH1_REF_PCNT0(32'b0),
        .MATCH1_REF_PCNT1(32'b0),
        .MATCH1_REF_PCNT2(32'b0)
    ) u_ccb1 (
        .ccb_event_i(ccb_event1_i),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i   (rdata3_i),
        .rdata1_i   (rdata4_i),
        .rdata2_i   (rdata5_i),
`endif
        .match0_ref0_o(match0_ref3_o),
        .match1_ref0_o(match1_ref3_o),
        .load_val0_o  (load_val3_o),
        .match0_ref1_o(match0_ref4_o),
        .match1_ref1_o(match1_ref4_o),
        .load_val1_o  (load_val4_o),
        .match0_ref2_o(match0_ref5_o),
        .match1_ref2_o(match1_ref5_o),
        .load_val2_o  (load_val5_o)
    );


    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt2 (
        .clk_i(clk_i),
        .rst_i(rst_ni & (!rst_pulse)),
        .up_down_i(1'b1),
        .event_i(epwm_1a_n),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref3_o),  //(32'd10),
        .ccb_match1_ref_i(match1_ref3_o),  //(32'd0),
        .ccb_load_val_i(load_val3_o),  //(32'd0),
        .match0_o(pcnt2_match0_w),
        .match1_o(pcnt2_match1_w),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(rdata3_i),
`endif
        .zero_o(pcnt2_zero)
    );


    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt3 (
        .clk_i(clk_i),
        .rst_i(rst_ni & (!rst_pulse)),
        .up_down_i(1'b1),
        .event_i(epwm_1b_n),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref4_o),  //(32'd10),
        .ccb_match1_ref_i(match1_ref4_o),  //(32'd0),
        .ccb_load_val_i(load_val4_o),  //(32'd0),
        .match0_o(pcnt3_match0_w),
        .match1_o(pcnt3_match1_w),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(rdata4_i),
`endif
        .zero_o(pcnt3_zero)
    );

    // internal reset pulse
    rf_pulse_gen u_rst_pulse_gen (
        .clk_i   (clk_i),     // system clock
        .rst_ni  (rst_ni),   // system reset, active low
        .signal_i(int_rstn_1),  // input signal to trigger the pulse
        .pulse_o (rst_pulse)    // output pulse signal
    );

    // epwm 1a negedge pulse
    rf_pulse_gen epwm_1a_n_inst (
        .clk_i   (clk_i),     // system clock
        .rst_ni  (rst_ni),   // system reset, active low
        .signal_i(~epwm_1a_i),  // input signal to trigger the pulse
        .pulse_o (epwm_1a_n)    // output pulse signal
    );


    // epwm 1a posedge pulse
    rf_pulse_gen epwm_1a_p_inst (
        .clk_i   (clk_i),    // system clock
        .rst_ni  (rst_ni),  // system reset, active low
        .signal_i(epwm_1a_i),  // input signal to trigger the pulse
        .pulse_o (epwm_1a_p)   // output pulse signal
    );

    // epwm 1b negedge pulse
    rf_pulse_gen epwm_1b_n_inst (
        .clk_i   (clk_i),     // system clock
        .rst_ni  (rst_ni),   // system reset, active low
        .signal_i(~epwm_1b_i),  // input signal to trigger the pulse
        .pulse_o (epwm_1b_n)    // output pulse signal
    );

    // epwm 1b posedge pulse
    rf_pulse_gen epwm_1b_p_inst (
        .clk_i   (clk_i),    // system clock
        .rst_ni  (rst_ni),  // system reset, active low
        .signal_i(epwm_1b_i),  // input signal to trigger the pulse
        .pulse_o (epwm_1b_p)   // output pulse signal
    );


endmodule
