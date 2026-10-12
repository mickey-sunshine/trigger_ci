
module pcnt32_srstp (
    input  wire       clk_i,
    input  wire       rst_i,      // 高电平复位
    input  wire [9:0] up_down_i,
    input  wire [9:0] event_i,
    input  wire [9:0] enable_i,
    output wire [9:0] match0_o,
    output wire [9:0] match1_o,
    output wire [9:0] zero_o
);

    pcounter32_clkp_srstp_load #(
        .LOAD_VAL  (32'd10 + 32'd0),
        .MATCH0_REF(32'd20 + 32'd0),
        .MATCH1_REF(32'd30 + 32'd0)
    ) inst_pcnt_0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[0]),
        .event_i(event_i[0]),
        .enable_i(enable_i[0]),
        .match0_o(match0_o[0]),
        .match1_o(match1_o[0]),
        .zero_o(zero_o[0])
    );


    pcounter32_clkn_srstp_load #(
        .LOAD_VAL  (32'd10 + 32'd1),
        .MATCH0_REF(32'd20 + 32'd1),
        .MATCH1_REF(32'd30 + 32'd1)
    ) inst_pcnt_1 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[1]),
        .event_i(event_i[1]),
        .enable_i(enable_i[1]),
        .match0_o(match0_o[1]),
        .match1_o(match1_o[1]),
        .zero_o(zero_o[1])
    );


    pcounter32_clkp_srstp_add #(
        .LOAD_VAL  (32'd10 + 32'd2),
        .MATCH0_REF(32'd20 + 32'd2),
        .MATCH1_REF(32'd30 + 32'd2)
    ) inst_pcnt_2 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[2]),
        .event_i(event_i[2]),
        .enable_i(enable_i[2]),
        .match0_o(match0_o[2]),
        .match1_o(match1_o[2]),
        .zero_o(zero_o[2])
    );


    pcounter32_clkn_srstp_add #(
        .LOAD_VAL  (32'd10 + 32'd3),
        .MATCH0_REF(32'd20 + 32'd3),
        .MATCH1_REF(32'd30 + 32'd3)
    ) inst_pcnt_3 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[3]),
        .event_i(event_i[3]),
        .enable_i(enable_i[3]),
        .match0_o(match0_o[3]),
        .match1_o(match1_o[3]),
        .zero_o(zero_o[3])
    );


    pcounter32_clkp_srstp_sub #(
        .LOAD_VAL  (32'd10 + 32'd4),
        .MATCH0_REF(32'd20 + 32'd4),
        .MATCH1_REF(32'd30 + 32'd4)
    ) inst_pcnt_4 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[4]),
        .event_i(event_i[4]),
        .enable_i(enable_i[4]),
        .match0_o(match0_o[4]),
        .match1_o(match1_o[4]),
        .zero_o(zero_o[4])
    );


    pcounter32_clkn_srstp_sub #(
        .LOAD_VAL  (32'd10 + 32'd5),
        .MATCH0_REF(32'd20 + 32'd5),
        .MATCH1_REF(32'd30 + 32'd5)
    ) inst_pcnt_5 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[5]),
        .event_i(event_i[5]),
        .enable_i(enable_i[5]),
        .match0_o(match0_o[5]),
        .match1_o(match1_o[5]),
        .zero_o(zero_o[5])
    );


    pcounter32_clkp_srstp_sl #(
        .LOAD_VAL  (32'd10 + 32'd6),
        .MATCH0_REF(32'd20 + 32'd6),
        .MATCH1_REF(32'd30 + 32'd6)
    ) inst_pcnt_6 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[6]),
        .event_i(event_i[6]),
        .enable_i(enable_i[6]),
        .match0_o(match0_o[6]),
        .match1_o(match1_o[6]),
        .zero_o(zero_o[6])
    );


    pcounter32_clkn_srstp_sl #(
        .LOAD_VAL  (32'd10 + 32'd7),
        .MATCH0_REF(32'd20 + 32'd7),
        .MATCH1_REF(32'd30 + 32'd7)
    ) inst_pcnt_7 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[7]),
        .event_i(event_i[7]),
        .enable_i(enable_i[7]),
        .match0_o(match0_o[7]),
        .match1_o(match1_o[7]),
        .zero_o(zero_o[7])
    );


    pcounter32_clkp_srstp_sr #(
        .LOAD_VAL  (32'd10 + 32'd8),
        .MATCH0_REF(32'd20 + 32'd8),
        .MATCH1_REF(32'd30 + 32'd8)
    ) inst_pcnt_8 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[8]),
        .event_i(event_i[8]),
        .enable_i(enable_i[8]),
        .match0_o(match0_o[8]),
        .match1_o(match1_o[8]),
        .zero_o(zero_o[8])
    );


    pcounter32_clkn_srstp_sr #(
        .LOAD_VAL  (32'd10 + 32'd9),
        .MATCH0_REF(32'd20 + 32'd9),
        .MATCH1_REF(32'd30 + 32'd9)
    ) inst_pcnt_9 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .up_down_i(up_down_i[9]),
        .event_i(event_i[9]),
        .enable_i(enable_i[9]),
        .match0_o(match0_o[9]),
        .match1_o(match1_o[9]),
        .zero_o(zero_o[9])
    );

endmodule
