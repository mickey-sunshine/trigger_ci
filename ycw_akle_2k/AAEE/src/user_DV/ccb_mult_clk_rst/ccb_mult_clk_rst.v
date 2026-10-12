//`define FULL_CCB_MODEL_FOR_SIM 1
module ccb_mult_clk_rst (
    input  wire clk1_i,   // System clock
    input  wire clk2_i,   // System clock
    input  wire rst1_ni,  // Active low reset
    input  wire rst2_ni,  // Active low reset
    input  wire a_i,
    input  wire b_i,
    output wire c_o,
    output reg  d_o,
    output reg  pcnt_o
);


    wire [31:0] match0_ref0_o, match1_ref0_o, load_val0_o;
    wire [31:0] match0_ref1_o, match1_ref1_o, load_val1_o;
    wire [31:0] match0_ref2_o, match1_ref2_o, load_val2_o;
    wire pcnt2_match0, pcnt2_match1;
    assign c_o = a_i & b_i;
    always @(posedge clk1_i or negedge rst1_ni) begin
        if (!rst1_ni) begin
            d_o <= 1'b0;
        end else begin
            d_o <= c_o;
        end
    end

    always @(posedge clk2_i or negedge rst2_ni) begin
        if (!rst2_ni) begin
            pcnt_o <= 1'b0;
        end else begin
            if (pcnt2_match0) pcnt_o <= ~pcnt_o;
            else pcnt_o <= pcnt_o;
        end
    end
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // PCNT initial values
        .LOAD_VAL_PCNT0({32{1'b0}}),
        .LOAD_VAL_PCNT1({32{1'b0}}),
        .LOAD_VAL_PCNT2({32{1'b0}}),
        .MATCH0_REF_PCNT0({32{1'b0}}),
        .MATCH0_REF_PCNT1({32{1'b0}}),
        .MATCH0_REF_PCNT2(32'd25),
        .MATCH1_REF_PCNT0({32{1'b0}}),
        .MATCH1_REF_PCNT1({32{1'b0}}),
        .MATCH1_REF_PCNT2(32'd50)
    ) u_ccb (
        .ccb_clk_i    (clk2_i),
        .ccb_rst_ni   (rst2_ni),
        .ccb_event_i  (4'b0),
        .pcnt_event_i (3'b0),
        // Enable only when a_o RTL-level simulation before synthesis is required
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


    /* counter 3 */
    // 修改match0、match1后生成pwm
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_pwm_o (
        .clk_i           (clk2_i),
        .rst_i           (rst2_ni),
        .up_down_i       (1'b0),
        .event_i         (pcnt2_match1),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(match0_ref2_o),
        .ccb_match1_ref_i(match1_ref2_o),
        .ccb_load_val_i  (load_val2_o),

        .match0_o(pcnt2_match0),
        .match1_o(pcnt2_match1),
        // Enable only when a_o RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

endmodule
