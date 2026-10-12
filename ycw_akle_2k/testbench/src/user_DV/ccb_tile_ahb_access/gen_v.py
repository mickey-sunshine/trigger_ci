import os

template = """
    wire [ 2:0] ccb_{ccb_idenx}_pwm_o;
    wire [ 2:0] ccb_{ccb_idenx}_pcnt_rst;
    wire [31:0] ccb_{ccb_idenx}_match0_ref0_o;
    wire [31:0] ccb_{ccb_idenx}_match1_ref0_o;
    wire [31:0] ccb_{ccb_idenx}_load_val0_o;
    wire [31:0] ccb_{ccb_idenx}_match0_ref1_o;
    wire [31:0] ccb_{ccb_idenx}_match1_ref1_o;
    wire [31:0] ccb_{ccb_idenx}_load_val1_o;
    wire [31:0] ccb_{ccb_idenx}_match0_ref2_o;
    wire [31:0] ccb_{ccb_idenx}_match1_ref2_o;
    wire [31:0] ccb_{ccb_idenx}_load_val2_o;
    localparam CCB_{ccb_idenx}_R0 = (32'd{ccb_idenx} * 32'd100) + 32'd0;
    localparam CCB_{ccb_idenx}_R1 = (32'd{ccb_idenx} * 32'd100) + 32'd1;
    localparam CCB_{ccb_idenx}_R2 = (32'd{ccb_idenx} * 32'd100) + 32'd2;
    localparam CCB_{ccb_idenx}_R3 = (32'd{ccb_idenx} * 32'd100) + 32'd3;
    localparam CCB_{ccb_idenx}_FIFO_INIT0 = (32'd{ccb_idenx} * 32'd100) + 32'd4;
    localparam CCB_{ccb_idenx}_FIFO_INIT1 = (32'd{ccb_idenx} * 32'd100) + 32'd5;
    localparam CCB_{ccb_idenx}_FIFO_INIT2 = (32'd{ccb_idenx} * 32'd100) + 32'd6;
    localparam CCB_{ccb_idenx}_FIFO_INIT3 = (32'd{ccb_idenx} * 32'd100) + 32'd7;
    localparam CCB_{ccb_idenx}_PCNT_0_LOAD_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd10;
    localparam CCB_{ccb_idenx}_PCNT_1_LOAD_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd20;
    localparam CCB_{ccb_idenx}_PCNT_2_LOAD_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd30;
    localparam CCB_{ccb_idenx}_PCNT_0_MATCH0_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd11;
    localparam CCB_{ccb_idenx}_PCNT_1_MATCH0_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd21;
    localparam CCB_{ccb_idenx}_PCNT_2_MATCH0_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd31;
    localparam CCB_{ccb_idenx}_PCNT_0_MATCH1_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd12;
    localparam CCB_{ccb_idenx}_PCNT_1_MATCH1_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd22;
    localparam CCB_{ccb_idenx}_PCNT_2_MATCH1_VAL = (32'd{ccb_idenx} * 32'd100) + 32'd32;
    // Timer implementation goes here
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y({ccb_idenx}.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({{`ADD, `R3, `R0}}),
        .EVENT0_INST1({{`PUSH, `R0, 3'b000}}),
        .EVENT0_INST2({{`ADD, `R3, `R0}}),
        .EVENT0_INST3({{`PUSH, `R0, 3'b000}}),
        .EVENT0_INST4({{`ADD, `R3, `R0}}),
        .EVENT0_INST5({{`PUSH, `R0, 3'b000}}),
        .EVENT0_INST6({{`ADD, `R3, `R0}}),
        .EVENT0_INST7({{`PUSH, `R0, 3'b000}}),
        // Initial register values, R0-R3
        .R0(CCB_{ccb_idenx}_R0),
        .R1(CCB_{ccb_idenx}_R1),
        .R2(CCB_{ccb_idenx}_R2),
        .R3(CCB_{ccb_idenx}_R3),
        // FIFO initial values
        .FIFO_INIT0(CCB_{ccb_idenx}_FIFO_INIT0),
        .FIFO_INIT1(CCB_{ccb_idenx}_FIFO_INIT1),
        .FIFO_INIT2(CCB_{ccb_idenx}_FIFO_INIT2),
        .FIFO_INIT3(CCB_{ccb_idenx}_FIFO_INIT3),
        // PCNT initial values
        .LOAD_VAL_PCNT0(CCB_{ccb_idenx}_PCNT_0_LOAD_VAL),
        .LOAD_VAL_PCNT1(CCB_{ccb_idenx}_PCNT_1_LOAD_VAL),
        .LOAD_VAL_PCNT2(CCB_{ccb_idenx}_PCNT_2_LOAD_VAL),
        .MATCH0_REF_PCNT0(CCB_{ccb_idenx}_PCNT_0_MATCH0_VAL),
        .MATCH0_REF_PCNT1(CCB_{ccb_idenx}_PCNT_1_MATCH0_VAL),
        .MATCH0_REF_PCNT2(CCB_{ccb_idenx}_PCNT_2_MATCH0_VAL),
        .MATCH1_REF_PCNT0(CCB_{ccb_idenx}_PCNT_0_MATCH1_VAL),
        .MATCH1_REF_PCNT1(CCB_{ccb_idenx}_PCNT_1_MATCH1_VAL),
        .MATCH1_REF_PCNT2(CCB_{ccb_idenx}_PCNT_2_MATCH1_VAL)
    ) u_ccb_{ccb_idenx} (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({{event_trig_i[{ccb_idenx1}], 3'b0}}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(ccb_{ccb_idenx}_match0_ref0_o),
        .match1_ref0_o(ccb_{ccb_idenx}_match1_ref0_o),
        .load_val0_o  (ccb_{ccb_idenx}_load_val0_o),
        .match0_ref1_o(ccb_{ccb_idenx}_match0_ref1_o),
        .match1_ref1_o(ccb_{ccb_idenx}_match1_ref1_o),
        .load_val1_o  (ccb_{ccb_idenx}_load_val1_o),
        .match0_ref2_o(ccb_{ccb_idenx}_match0_ref2_o),
        .match1_ref2_o(ccb_{ccb_idenx}_match1_ref2_o),
        .load_val2_o  (ccb_{ccb_idenx}_load_val2_o)
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y({ccb_idenx}.0),
        .FPGA_LOC_Z(1.0)
    ) pcnt_3{ccb_idenx}0 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_{ccb_idenx}_pcnt_rst[0]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_{ccb_idenx}_match0_ref0_o),
        .ccb_match1_ref_i(ccb_{ccb_idenx}_match1_ref0_o),
        .ccb_load_val_i  (ccb_{ccb_idenx}_load_val0_o),

        .match0_o(ccb_{ccb_idenx}_pwm_o[0]),
        .match1_o(ccb_{ccb_idenx}_pcnt_rst[0]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y({ccb_idenx}.0),
        .FPGA_LOC_Z(2.0)
    ) pcnt_3{ccb_idenx}1 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_{ccb_idenx}_pcnt_rst[1]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_{ccb_idenx}_match0_ref1_o),
        .ccb_match1_ref_i(ccb_{ccb_idenx}_match1_ref1_o),
        .ccb_load_val_i  (ccb_{ccb_idenx}_load_val1_o),

        .match0_o(ccb_{ccb_idenx}_pwm_o[1]),
        .match1_o(ccb_{ccb_idenx}_pcnt_rst[1]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

    /* 计时器 */
    pcounter32_clkp_arstn_load_ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y({ccb_idenx}.0),
        .FPGA_LOC_Z(3.0)
    ) pcnt_3{ccb_idenx}2 (
        .clk_i           (clk_i),
        .rst_i           (rst_ni),
        .up_down_i       (1'b0),
        .event_i         (ccb_{ccb_idenx}_pcnt_rst[2]),
        .enable_i        (1'b1),
        .ccb_match0_ref_i(ccb_{ccb_idenx}_match0_ref2_o),
        .ccb_match1_ref_i(ccb_{ccb_idenx}_match1_ref2_o),
        .ccb_load_val_i  (ccb_{ccb_idenx}_load_val2_o),

        .match0_o(ccb_{ccb_idenx}_pwm_o[2]),
        .match1_o(ccb_{ccb_idenx}_pcnt_rst[2]),
`ifdef FULL_CCB_MODEL_FOR_SIM
        .q_o     (),
`endif
        .zero_o  ()
    );

"""
head = """
module ccb_tile_ahb_access (
    input  wire        clk_i,
    input  wire        clk_ccb_i,
    input  wire        rst_ni,
    input  wire [ 5:0] event_trig_i,  // 触发ccb事件
    output wire [17:0] pwm_o          // pwm_out
);
"""
if __name__ == "__main__":

    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, "ccb_tile_ahb_access.v")
    full_code = ""
    code = ""
    output_assign = "    assign pwm_o = {"
    for i in range(1, 7):
        output_assign += "ccb_{ccb_idenx}_pwm_o, ".format(ccb_idenx=i)
        code += template.format(ccb_idenx=i, ccb_idenx1=i - 1)
    output_assign = output_assign[:-2]
    output_assign += "};\n"
    full_code += head
    full_code += code
    full_code += output_assign
    full_code += "endmodule"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(full_code)
