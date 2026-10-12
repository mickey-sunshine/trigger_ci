module c2k_sig_gen_check_ccb (
    input  wire       clk_i,         // 时钟信号
    input  wire       rst_ni,        // 低电平复位
    input  wire       pwm_sel_i,     // tb给的干扰信号, =1时就选用tb的信号
    input  wire       pwm_err_i,     // tb给的干扰信号, 模拟pwm错误
    input  wire [3:0] event_ccb_i,   // 事件触发, 切换pcnt的预设值
    output reg        pwm_out_o,
    output wire       interrupt1_o,
    output wire       interrupt2_o
);

    localparam PC1_MATCH0 = 32'd200;
    localparam PC1_MATCH1 = 32'd400;
    localparam PC2_MATCH0 = 32'd300;  // 占空比预设值
    localparam PC3_MATCH0 = 32'd500;  // 周期预设值
    localparam PC2_MATCH0_2 = 32'd99;  // 占空比预设值2
    localparam PC3_MATCH0_2 = 32'd350;  // 周期预设值2

    wire pc1_rst;
    wire pc1_zero;
    reg  pwm_pcntout;
    reg  pwm_out_o_d1;
    reg  interrupt1_o_d1;
    reg  interrupt2_o_d1;
    wire f_edge_pwm_out_o;

    wire [31:0] match0_ref0, match0_ref1, match0_ref2;
    wire [31:0] match1_ref0, match1_ref1, match1_ref2;
    wire [31:0] load_val0, load_val1, load_val2;


    wire pcnt1_event, pcnt2_event, pcnt3_event;
    wire [5:0] ccb_pcnt_event;
    assign pcnt1_event = pc1_rst;
    assign pcnt2_event = (~pwm_out_o) | interrupt1_o_d1;
    assign pcnt3_event = 1'b1;
    assign ccb_pcnt_event = {pcnt1_event, 1'b0, pcnt2_event, 1'b0, pcnt3_event, 1'b0};

    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`MOV_T1, `R0, `C1}),
        .EVENT0_INST1({`MOV_T1, `R1, `C2}),
        // Event1 triggered instructions
        .EVENT1_INST0({`MOV_T1, `R2, `C1}),
        .EVENT1_INST1({`MOV_T1, `R3, `C2}),
        // Initial register values, R0-R3
        .R0(PC2_MATCH0),
        .R1(PC3_MATCH0),
        .R2(PC2_MATCH0_2),
        .R3(PC3_MATCH0_2),
        // PCNT initial values
        .LOAD_VAL_PCNT0({32{1'b0}}),
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0(PC1_MATCH0),
        .MATCH0_REF_PCNT1(PC2_MATCH0),
        .MATCH0_REF_PCNT2(PC3_MATCH0),
        .MATCH1_REF_PCNT0(PC1_MATCH1),
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2({32{1'b0}})
    ) u_ccb (
        .ccb_clk_i    (clk_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (event_ccb_i),
        .pcnt_event_i (ccb_pcnt_event),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(match0_ref0),
        .match1_ref0_o(match1_ref0),
        .load_val0_o  (load_val0),
        .match0_ref1_o(match0_ref1),
        .match1_ref1_o(match1_ref1),
        .load_val1_o  (load_val1),
        .match0_ref2_o(match0_ref2),
        .match1_ref2_o(match1_ref2),
        .load_val2_o  (load_val2)
    );


    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(1.0)
    ) pc1_pwm_gen (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(pcnt1_event),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref0),
        .ccb_match1_ref_i(match1_ref0),
        .ccb_load_val_i(load_val0),
        .match0_o(pc1_match0),
        .match1_o(pc1_rst),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(),
`endif
        .zero_o(pc1_zero)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_pcntout <= 1'b0;
        end else begin
            if (pc1_match0 == 1) begin
                pwm_pcntout <= 1'b1;
            end else if (pc1_zero == 1) begin
                pwm_pcntout <= 1'b0;
            end else begin
                pwm_pcntout <= pwm_pcntout;
            end
        end
    end
    assign pwm_out_o = pwm_sel_i ? pwm_err_i : pwm_pcntout;
    assign f_edge_pwm_out_o = pwm_out_o_d1 & (~pwm_out_o);
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_out_o_d1 <= 1'b0;
            interrupt1_o_d1 <= 1'b0;
            interrupt2_o_d1 <= 1'b0;
        end else begin
            pwm_out_o_d1 <= pwm_out_o;
            interrupt1_o_d1 <= interrupt1_o;
            interrupt2_o_d1 <= interrupt2_o;
        end
    end

    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0)
    ) pc2_detector_on_time (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(pcnt2_event),
        .enable_i(pwm_out_o_d1),
        .ccb_match0_ref_i(match0_ref1),
        .ccb_match1_ref_i(match1_ref1),
        .ccb_load_val_i(load_val1),
        .match0_o(interrupt1_o),
        .match1_o(),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(),
`endif
        .zero_o()
    );

    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(3.0)
    ) pc3_detector_period (
        .clk_i(clk_i),
        .rst_i(rst_ni & (~f_edge_pwm_out_o) & (~interrupt2_o_d1)),
        .up_down_i(1'b0),
        .event_i(1'b0),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref2),
        .ccb_match1_ref_i(match1_ref2),
        .ccb_load_val_i(load_val2),
        .match0_o(interrupt2_o),
        .match1_o(),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o(),
`endif
        .zero_o()
    );
endmodule
