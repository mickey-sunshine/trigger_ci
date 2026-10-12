
module pcnt16_arstpn (
    input  wire        clk_i,
    input  wire        rst_ni,     // 低电平复位
    input  wire        rst_pi,     // 高电平复位
    input  wire [19:0] up_down_i,
    input  wire [19:0] event_i,
    input  wire [19:0] enable_i,
    output wire [19:0] match0_o,
    output wire [19:0] match1_o,
    output wire [19:0] zero_o
);

    pcounter16_clkp_arstp_sl #(
        .LOAD_VAL  (16'd0 + 16'd0),
        .MATCH0_REF(16'd20 + 16'd0),
        .MATCH1_REF(16'd30 + 16'd0)
    ) inst_pcnt_0 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[0]),
        .event_i(event_i[0]),
        .enable_i(enable_i[0]),
        .match0_o(match0_o[0]),
        .match1_o(match1_o[0]),
        .zero_o(zero_o[0])
    );


    pcounter16_clkp_arstn_sl #(
        .LOAD_VAL  (16'd0 + 16'd1),
        .MATCH0_REF(16'd20 + 16'd1),
        .MATCH1_REF(16'd30 + 16'd1)
    ) inst_pcnt_1 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[1]),
        .event_i(event_i[1]),
        .enable_i(enable_i[1]),
        .match0_o(match0_o[1]),
        .match1_o(match1_o[1]),
        .zero_o(zero_o[1])
    );


    pcounter16_clkn_arstp_sl #(
        .LOAD_VAL  (16'd0 + 16'd2),
        .MATCH0_REF(16'd20 + 16'd2),
        .MATCH1_REF(16'd30 + 16'd2)
    ) inst_pcnt_2 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[2]),
        .event_i(event_i[2]),
        .enable_i(enable_i[2]),
        .match0_o(match0_o[2]),
        .match1_o(match1_o[2]),
        .zero_o(zero_o[2])
    );


    pcounter16_clkn_arstn_sl #(
        .LOAD_VAL  (16'd0 + 16'd3),
        .MATCH0_REF(16'd20 + 16'd3),
        .MATCH1_REF(16'd30 + 16'd3)
    ) inst_pcnt_3 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[3]),
        .event_i(event_i[3]),
        .enable_i(enable_i[3]),
        .match0_o(match0_o[3]),
        .match1_o(match1_o[3]),
        .zero_o(zero_o[3])
    );


    pcounter16_clkp_arstp_sr #(
        .LOAD_VAL  (16'd0 + 16'd4),
        .MATCH0_REF(16'd20 + 16'd4),
        .MATCH1_REF(16'd30 + 16'd4)
    ) inst_pcnt_4 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[4]),
        .event_i(event_i[4]),
        .enable_i(enable_i[4]),
        .match0_o(match0_o[4]),
        .match1_o(match1_o[4]),
        .zero_o(zero_o[4])
    );


    pcounter16_clkp_arstn_sr #(
        .LOAD_VAL  (16'd0 + 16'd5),
        .MATCH0_REF(16'd20 + 16'd5),
        .MATCH1_REF(16'd30 + 16'd5)
    ) inst_pcnt_5 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[5]),
        .event_i(event_i[5]),
        .enable_i(enable_i[5]),
        .match0_o(match0_o[5]),
        .match1_o(match1_o[5]),
        .zero_o(zero_o[5])
    );


    pcounter16_clkn_arstp_sr #(
        .LOAD_VAL  (16'd0 + 16'd6),
        .MATCH0_REF(16'd20 + 16'd6),
        .MATCH1_REF(16'd30 + 16'd6)
    ) inst_pcnt_6 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[6]),
        .event_i(event_i[6]),
        .enable_i(enable_i[6]),
        .match0_o(match0_o[6]),
        .match1_o(match1_o[6]),
        .zero_o(zero_o[6])
    );


    pcounter16_clkn_arstn_sr #(
        .LOAD_VAL  (16'd0 + 16'd7),
        .MATCH0_REF(16'd20 + 16'd7),
        .MATCH1_REF(16'd30 + 16'd7)
    ) inst_pcnt_7 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[7]),
        .event_i(event_i[7]),
        .enable_i(enable_i[7]),
        .match0_o(match0_o[7]),
        .match1_o(match1_o[7]),
        .zero_o(zero_o[7])
    );


    pcounter16_clkp_arstp_load #(
        .LOAD_VAL  (16'd0 + 16'd8),
        .MATCH0_REF(16'd20 + 16'd8),
        .MATCH1_REF(16'd30 + 16'd8)
    ) inst_pcnt_8 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[8]),
        .event_i(event_i[8]),
        .enable_i(enable_i[8]),
        .match0_o(match0_o[8]),
        .match1_o(match1_o[8]),
        .zero_o(zero_o[8])
    );


    pcounter16_clkp_arstn_load #(
        .LOAD_VAL  (16'd0 + 16'd9),
        .MATCH0_REF(16'd20 + 16'd9),
        .MATCH1_REF(16'd30 + 16'd9)
    ) inst_pcnt_9 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[9]),
        .event_i(event_i[9]),
        .enable_i(enable_i[9]),
        .match0_o(match0_o[9]),
        .match1_o(match1_o[9]),
        .zero_o(zero_o[9])
    );


    pcounter16_clkn_arstp_load #(
        .LOAD_VAL  (16'd0 + 16'd10),
        .MATCH0_REF(16'd20 + 16'd10),
        .MATCH1_REF(16'd30 + 16'd10)
    ) inst_pcnt_10 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[10]),
        .event_i(event_i[10]),
        .enable_i(enable_i[10]),
        .match0_o(match0_o[10]),
        .match1_o(match1_o[10]),
        .zero_o(zero_o[10])
    );


    pcounter16_clkn_arstn_load #(
        .LOAD_VAL  (16'd0 + 16'd11),
        .MATCH0_REF(16'd20 + 16'd11),
        .MATCH1_REF(16'd30 + 16'd11)
    ) inst_pcnt_11 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[11]),
        .event_i(event_i[11]),
        .enable_i(enable_i[11]),
        .match0_o(match0_o[11]),
        .match1_o(match1_o[11]),
        .zero_o(zero_o[11])
    );


    pcounter16_clkp_arstp_add #(
        .LOAD_VAL  (16'd0 + 16'd12),
        .MATCH0_REF(16'd20 + 16'd12),
        .MATCH1_REF(16'd30 + 16'd12)
    ) inst_pcnt_12 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[12]),
        .event_i(event_i[12]),
        .enable_i(enable_i[12]),
        .match0_o(match0_o[12]),
        .match1_o(match1_o[12]),
        .zero_o(zero_o[12])
    );


    pcounter16_clkp_arstn_add #(
        .LOAD_VAL  (16'd0 + 16'd13),
        .MATCH0_REF(16'd20 + 16'd13),
        .MATCH1_REF(16'd30 + 16'd13)
    ) inst_pcnt_13 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[13]),
        .event_i(event_i[13]),
        .enable_i(enable_i[13]),
        .match0_o(match0_o[13]),
        .match1_o(match1_o[13]),
        .zero_o(zero_o[13])
    );


    pcounter16_clkn_arstp_add #(
        .LOAD_VAL  (16'd0 + 16'd14),
        .MATCH0_REF(16'd20 + 16'd14),
        .MATCH1_REF(16'd30 + 16'd14)
    ) inst_pcnt_14 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[14]),
        .event_i(event_i[14]),
        .enable_i(enable_i[14]),
        .match0_o(match0_o[14]),
        .match1_o(match1_o[14]),
        .zero_o(zero_o[14])
    );


    pcounter16_clkn_arstn_add #(
        .LOAD_VAL  (16'd0 + 16'd15),
        .MATCH0_REF(16'd20 + 16'd15),
        .MATCH1_REF(16'd30 + 16'd15)
    ) inst_pcnt_15 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[15]),
        .event_i(event_i[15]),
        .enable_i(enable_i[15]),
        .match0_o(match0_o[15]),
        .match1_o(match1_o[15]),
        .zero_o(zero_o[15])
    );


    pcounter16_clkp_arstp_sub #(
        .LOAD_VAL  (16'd0 + 16'd16),
        .MATCH0_REF(16'd20 + 16'd16),
        .MATCH1_REF(16'd30 + 16'd16)
    ) inst_pcnt_16 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[16]),
        .event_i(event_i[16]),
        .enable_i(enable_i[16]),
        .match0_o(match0_o[16]),
        .match1_o(match1_o[16]),
        .zero_o(zero_o[16])
    );


    pcounter16_clkp_arstn_sub #(
        .LOAD_VAL  (16'd0 + 16'd17),
        .MATCH0_REF(16'd20 + 16'd17),
        .MATCH1_REF(16'd30 + 16'd17)
    ) inst_pcnt_17 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[17]),
        .event_i(event_i[17]),
        .enable_i(enable_i[17]),
        .match0_o(match0_o[17]),
        .match1_o(match1_o[17]),
        .zero_o(zero_o[17])
    );


    pcounter16_clkn_arstp_sub #(
        .LOAD_VAL  (16'd0 + 16'd18),
        .MATCH0_REF(16'd20 + 16'd18),
        .MATCH1_REF(16'd30 + 16'd18)
    ) inst_pcnt_18 (
        .clk_i(clk_i),
        .rst_i(rst_pi),
        .up_down_i(up_down_i[18]),
        .event_i(event_i[18]),
        .enable_i(enable_i[18]),
        .match0_o(match0_o[18]),
        .match1_o(match1_o[18]),
        .zero_o(zero_o[18])
    );


    pcounter16_clkn_arstn_sub #(
        .LOAD_VAL  (16'd0 + 16'd19),
        .MATCH0_REF(16'd20 + 16'd19),
        .MATCH1_REF(16'd30 + 16'd19)
    ) inst_pcnt_19 (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[19]),
        .event_i(event_i[19]),
        .enable_i(enable_i[19]),
        .match0_o(match0_o[19]),
        .match1_o(match1_o[19]),
        .zero_o(zero_o[19])
    );

endmodule
