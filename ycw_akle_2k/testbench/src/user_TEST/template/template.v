module template (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire event_i,
    input  wire enable_i,
    output wire match0_o,
    output wire match1_o,
    output wire zero_o
);

    pcounter32_clkp_arstn_load #(
        .MATCH0_REF(32'd10),
        .MATCH1_REF(32'd20)
    ) counter_instance (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(event_i),
        .enable_i(enable_i),
        .match0_o(match0_o),
        .match1_o(match1_o),
        .zero_o(zero_o)
    );

endmodule
