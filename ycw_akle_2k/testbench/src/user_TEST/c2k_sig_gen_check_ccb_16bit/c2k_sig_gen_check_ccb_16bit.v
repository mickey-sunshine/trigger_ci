module c2k_sig_gen_check_ccb_16bit (
    input  wire       clk_i,         // 时钟信号
    input  wire       rst_ni,        // 低电平复位
    input  wire [3:0] event_ccb,     // 事件触发, 切换pcnt的预设值
    output reg        pwm_out,
    output wire       interrupt_o1,
    output wire       interrupt_o2
);

    localparam PC1_MATCH0 = 16'd200;
    localparam PC1_MATCH1 = 16'd400;
    localparam PC2_MATCH0 = 16'd300;  // 占空比预设值
    localparam PC2_MATCH0_2 = 16'd100;  // 占空比预设值2
    localparam PC3_MATCH0 = 16'd500;  // 周期预设值
    localparam PC3_MATCH0_2 = 16'd300;  // 周期预设值2

    wire pc1_rst;
    wire pc1_zero;
    // reg  pwm_out;
    reg  pwm_out_d1;
    reg  interrupt_o1_d1;
    reg  interrupt_o2_d1;
    wire f_edge_pwm_out;

    wire [15:0] match0_ref0_0, match0_ref1_0, match0_ref2_0;
    wire [15:0] match0_ref0_1, match0_ref1_1, match0_ref2_1;
    wire [15:0] match1_ref0_0, match1_ref1_0, match1_ref2_0;
    wire [15:0] match1_ref0_1, match1_ref1_1, match1_ref2_1;
    wire [15:0] load_val0_0, load_val1_0, load_val2_0;
    wire [15:0] load_val0_1, load_val1_1, load_val2_1;

    pcounter16_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(1.0)
    ) pc1_pwm_gen (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(pc1_rst),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref0_0),
        .ccb_match1_ref_i(match1_ref0_0),
        .ccb_load_val_i(load_val0_0),
        .match0_o(pc1_match0),
        .match1_o(pc1_rst),
        .zero_o(pc1_zero),
        .q_o()
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_out <= 1'b0;
        end else begin
            if (pc1_match0 == 1) begin
                pwm_out <= 1'b1;
            end else if (pc1_zero == 1) begin
                pwm_out <= 1'b0;
            end else begin
                pwm_out <= pwm_out;
            end
        end
    end

    assign f_edge_pwm_out = pwm_out_d1 & (~pwm_out);
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_out_d1 <= 1'b0;
            interrupt_o1_d1 <= 1'b0;
            interrupt_o2_d1 <= 1'b0;
        end else begin
            pwm_out_d1 <= pwm_out;
            interrupt_o1_d1 <= interrupt_o1;
            interrupt_o2_d1 <= interrupt_o2;
        end
    end

    pcounter16_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0)
    ) pc2_detector_on_time (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i((~pwm_out) | interrupt_o1_d1),
        .enable_i(pwm_out),
        .ccb_match0_ref_i(match0_ref1_0),
        .ccb_match1_ref_i(match1_ref1_0),
        .ccb_load_val_i(load_val1_0),
        .match0_o(interrupt_o1),
        .match1_o(),
        .zero_o(),
        .q_o()
    );

    pcounter16_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0)
    ) pc3_detector_period (
        .clk_i(clk_i),
        .rst_i(rst_ni & (~f_edge_pwm_out) & (~interrupt_o2_d1)),
        .up_down_i(1'b0),
        .event_i(),
        .enable_i(1'b1),
        .ccb_match0_ref_i(match0_ref1_1),
        .ccb_match1_ref_i(match1_ref1_1),
        .ccb_load_val_i(load_val1_1),
        .match0_o(interrupt_o2),
        .match1_o(),
        .zero_o(),
        .q_o()
    );
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`MOV_T1, `R0, `C1}),
        // Event1 triggered instructions
        .EVENT1_INST0({`MOV_T1, `R1, `C1}),
        // Initial register values, R0-R3
        .R0({PC3_MATCH0, PC2_MATCH0}),
        .R1({PC3_MATCH0_2, PC2_MATCH0_2}),
        .R2({32{1'b0}}),
        .R3({32{1'b0}}),
        // PCNT initial values
        .LOAD_VAL_PCNT0({32{1'b0}}),
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0({{16{1'b0}}, PC1_MATCH0}),
        .MATCH0_REF_PCNT1({PC3_MATCH0, PC2_MATCH0}),  // pc2 和 pc3 共用(3,2,2)的pcnt
        .MATCH0_REF_PCNT2({32{1'b0}}),
        .MATCH1_REF_PCNT0({{16{1'b0}}, PC1_MATCH1}),
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2({32{1'b0}})
    ) u_ccb (
        .ccb_clk_i    (clk_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  (event_ccb),
        // .pcnt_event_i (3'b111),
        // .rdata0_i     (32'b0),
        // .rdata1_i     (32'b0),
        // .rdata2_i     (32'b0),
        .match0_ref0_o({match0_ref0_1, match0_ref0_0}),
        .match1_ref0_o({match1_ref0_1, match1_ref0_0}),
        .load_val0_o  ({load_val0_1, load_val0_0}),
        .match0_ref1_o({match0_ref1_1, match0_ref1_0}),
        .match1_ref1_o({match1_ref1_1, match1_ref1_0}),
        .load_val1_o  ({load_val1_1, load_val1_0}),
        .match0_ref2_o({match0_ref2_1, match0_ref2_0}),
        .match1_ref2_o({match1_ref2_1, match1_ref2_0}),
        .load_val2_o  ({load_val2_1, load_val2_0})
    );
endmodule
