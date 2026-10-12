module cnt16_rst_clk (
    input  wire       clk_i,
    input  wire       rst_ni,
    input  wire       rst_i,
    input  wire [1:0] up_down_i,
    input  wire [1:0] event_i,
    output wire [1:0] match0_o,
    output wire [1:0] match1_o,
    output wire [1:0] zero_o
);

    pcounter16_clkn_arstn_load #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0),
        .LOAD_VAL  (16'd0),
        .MATCH0_REF(16'd10),
        .MATCH1_REF(16'd20)
    ) counter_instance0 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[0]),
        .event_i(event_i[0]),
        .enable_i(1'b1),
        .match0_o(match0_o[0]),
        .match1_o(match1_o[0]),
        .zero_o(zero_o[0])
    );

    pcounter16_clkp_srstp_load #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(1.0),
        .LOAD_VAL  (16'd50),
        .MATCH0_REF(16'd30),
        .MATCH1_REF(16'd45)
    ) counter_instance1 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[1]),
        .event_i(event_i[1]),
        .enable_i(1'b1),
        .match0_o(match0_o[1]),
        .match1_o(match1_o[1]),
        .zero_o(zero_o[1])
    );

endmodule
