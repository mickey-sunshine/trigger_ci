import os

template = """
    pcounter32_clk{clock_polarity}_arstn_{pcnt_mode} #(
        .LOAD_VAL  (32'd10 + 32'd{pcnt_index}),
        .MATCH0_REF(32'd20 + 32'd{pcnt_index}),
        .MATCH1_REF(32'd30 + 32'd{pcnt_index})
    ) inst_pcnt_{pcnt_index} (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(up_down_i[{pcnt_index}]),
        .event_i(event_i[{pcnt_index}]),
        .enable_i(enable_i[{pcnt_index}]),
        .match0_o(match0_o[{pcnt_index}]),
        .match1_o(match1_o[{pcnt_index}]),
        .zero_o(zero_o[{pcnt_index}])
    );
    
"""
head = """
module pcnt32_arstn (
    input  wire       clk_i,
    input  wire       rst_ni,      // 低电平复位
    input  wire [9:0] up_down_i,
    input  wire [9:0] event_i,
    input  wire [9:0] enable_i,
    output wire [9:0] match0_o,
    output wire [9:0] match1_o,
    output wire [9:0] zero_o
);
"""
pcnt_mode = ["load", "add", "sub", "sl", "sr"]
clock_polarity = ["p", "n"]
if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, "pcnt32_arstn.v")
    full_code = ""
    code = ""
    cnt = 0
    for mode in pcnt_mode:
        for polarity in clock_polarity:
            code += template.format(pcnt_index=cnt, clock_polarity=polarity, pcnt_mode=mode)
            cnt += 1

    full_code += head
    full_code += code
    full_code += "endmodule"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(full_code)
