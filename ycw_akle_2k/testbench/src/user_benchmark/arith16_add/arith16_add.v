module arith16_add (
    input wire clk_i,
    input wire rst_ni,
    input [1:0] up_down_i,
    input [1:0] event_i,
    input [1:0] enable_i,
    output [1:0] match0_o,
    output [1:0] match1_o,
    output [1:0] zero_o
);

    pcounter16_clkp_arstn_add #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(1.0),
        .LOAD_VAL  (16'hfff),
        .MATCH0_REF(16'h7fff),
        .MATCH1_REF(16'hffff)
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

    pcounter16_clkp_arstn_add #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(2.0),
        .FPGA_LOC_Z(1.0),
        .LOAD_VAL  (16'h1fff),
        .MATCH0_REF(16'h7fff),
        .MATCH1_REF(16'hffff)
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
