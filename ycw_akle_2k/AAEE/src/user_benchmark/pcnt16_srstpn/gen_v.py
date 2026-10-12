import os

template = """
    pcounter16_clk{clock_polarity}_srst{reset_polarity}_{pcnt_mode} #(
        .LOAD_VAL  (16'd0 + 16'd{pcnt_index}),
        .MATCH0_REF(16'd20 + 16'd{pcnt_index}),
        .MATCH1_REF(16'd30 + 16'd{pcnt_index})
    ) inst_pcnt_{pcnt_index} (
        .clk_i(clk_i),
        .rst_i(rst_{reset_polarity}i),
        .up_down_i(up_down_i[{pcnt_index}]),
        .event_i(event_i[{pcnt_index}]),
        .enable_i(enable_i[{pcnt_index}]),
        .match0_o(match0_o[{pcnt_index}]),
        .match1_o(match1_o[{pcnt_index}]),
        .zero_o(zero_o[{pcnt_index}])
    );
    
"""
head = """
module pcnt16_srstpn (
    input  wire       clk_i,
    input  wire       rst_ni,      // 低电平复位
    input  wire       rst_pi,      // 高电平复位
    input  wire [19:0] up_down_i,
    input  wire [19:0] event_i,
    input  wire [19:0] enable_i,
    output wire [19:0] match0_o,
    output wire [19:0] match1_o,
    output wire [19:0] zero_o
);
"""
pcnt_mode = ["sl", "sr", "load", "add", "sub"]
clock_polarity = ["p", "n"]
reset_polarity = ["p", "n"]
if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, "pcnt16_srstpn.v")
    full_code = ""
    code = ""
    cnt = 0
    for mode in pcnt_mode:
        for clk_pol in clock_polarity:
            for rst_pol in reset_polarity:
                code += template.format(
                    pcnt_index=cnt, clock_polarity=clk_pol, reset_polarity=rst_pol, pcnt_mode=mode
                )
                cnt += 1

    full_code += head
    full_code += code
    full_code += "endmodule"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(full_code)
