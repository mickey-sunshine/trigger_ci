module arith32_shift (
    input  wire       clk_i,
    input  wire       rst_ni,
    input  wire [1:0] up_down_i,
    input  wire [1:0] event_i,
    input  wire [1:0] enable_i,
    output wire [1:0] match0_o,
    output wire [1:0] match1_o,
    output wire [1:0] zero_o
);

    pcounter32_clkp_arstn_sr #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(6.0),
        .FPGA_LOC_Z(1.0),
        .LOAD_VAL  (32'h5),
        .MATCH0_REF(32'h3fffff),
        .MATCH1_REF(32'h7b)
    ) counter_instance0 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[0]),
        .event_i(event_i[0]),
        .enable_i(enable_i[0]),
        .match0_o(match0_o[0]),
        .match1_o(match1_o[0]),
        .zero_o(zero_o[0])
    );

    pcounter32_clkp_arstn_sl #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(6.0),
        .FPGA_LOC_Z(2.0),
        .LOAD_VAL  (32'h3),
        .MATCH0_REF(32'h47),
        .MATCH1_REF(32'h38000000)
    ) counter_instance1 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[1]),
        .event_i(event_i[1]),
        .enable_i(enable_i[1]),
        .match0_o(match0_o[1]),
        .match1_o(match1_o[1]),
        .zero_o(zero_o[1])
    );

endmodule
