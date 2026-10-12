module arith16_shift_left_right (
    input wire clk_i,
    input wire rst_ni,
    input [3:0] up_down_i,
    input [3:0] event_i,
    input [3:0] enable_i,
    output [3:0] match0_o,
    output [3:0] match1_o,
    output [3:0] zero_o
);
    pcounter16_clkp_arstn_sl #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0),
        .LOAD_VAL  (16'h3),
        .MATCH0_REF(16'h40),
        .MATCH1_REF(16'h1005)
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

    pcounter16_clkp_arstn_sr #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(2.0),
        .LOAD_VAL  (16'h2),
        .MATCH0_REF(16'hff),
        .MATCH1_REF(16'hf)
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

    pcounter16_clkp_arstn_sr #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(3.0),
        .LOAD_VAL  (16'h1),
        .MATCH0_REF(16'h7f),
        .MATCH1_REF(16'h1fff)
    ) counter_instance2 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[2]),
        .event_i(event_i[2]),
        .enable_i(enable_i[2]),
        .match0_o(match0_o[2]),
        .match1_o(match1_o[2]),
        .zero_o(zero_o[2])
    );

    pcounter16_clkp_arstn_sl #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(3.0),
        .LOAD_VAL  (16'h2),
        .MATCH0_REF(16'h8503),
        .MATCH1_REF(16'h85)
    ) counter_instance3 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[3]),
        .event_i(event_i[3]),
        .enable_i(enable_i[3]),
        .match0_o(match0_o[3]),
        .match1_o(match1_o[3]),
        .zero_o(zero_o[3])
    );

endmodule
