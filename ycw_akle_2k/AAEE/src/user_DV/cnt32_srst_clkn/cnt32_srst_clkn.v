module cnt32_srst_clkn (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire direction_i,
    output wire match0_o,
    output wire match1_o,
    output wire zero_o
);

    pcounter32_clkn_srstn_load #(
        .LOAD_VAL  (32'd0),
        .MATCH0_REF(32'd10),
        .MATCH1_REF(32'd20)
    ) counter_instance (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(direction_i),
        .event_i(1'b0),
        .enable_i(1'b1),
        .match0_o(match0_o),
        .match1_o(match1_o),
        .zero_o(zero_o)
    );

endmodule
