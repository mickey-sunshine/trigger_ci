
module cnt32_clkpn_rstas (
    input  wire       clk_i,
    input  wire       rst_ni,
    output wire [3:0] match_o
);

    wire [3:0] event_trig;
    pcounter32_clkp_arstn_load #(
        .MATCH0_REF(32'd6),
        .MATCH1_REF(32'd12)
    ) pcnt0_clkp_arstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(event_trig[0]),
        .enable_i(1'b1),
        .match0_o(match_o[0]),
        .match1_o(event_trig[0]),
        .zero_o()
    );

    pcounter32_clkn_arstn_load #(
        .MATCH0_REF(32'd6),
        .MATCH1_REF(32'd12)
    ) pcnt1_clkn_arstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(event_trig[1]),
        .enable_i(1'b1),
        .match0_o(match_o[1]),
        .match1_o(event_trig[1]),
        .zero_o()
    );
    pcounter32_clkp_srstn_load #(
        .MATCH0_REF(32'd6),
        .MATCH1_REF(32'd12)
    ) pcnt2_clkp_srstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(event_trig[2]),
        .enable_i(1'b1),
        .match0_o(match_o[2]),
        .match1_o(event_trig[2]),
        .zero_o()
    );
    pcounter32_clkn_srstn_load #(
        .MATCH0_REF(32'd6),
        .MATCH1_REF(32'd12)
    ) pcnt3_clkn_srstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(event_trig[3]),
        .enable_i(1'b1),
        .match0_o(match_o[3]),
        .match1_o(event_trig[3]),
        .zero_o()
    );


endmodule
