import os

template = """
    pcounter32_clkp_arstn_{pcnt_mode} #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y({Y_POS}.0),
        .FPGA_LOC_Z({Z_POS}.0),
        .LOAD_VAL  ({load_val}),
        .MATCH0_REF({match0_ref}),
        .MATCH1_REF({match1_ref})
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
module pcnt32_carry (
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
modes = ["load", "add", "sub", "sl", "sr"]
load_value = [
    ("32'h1_0000", "32'h1_0000", "32'hffff"),  # down load
    ("32'hffff", "32'hffff", "32'h1_0000"),  # up load
    ("32'h1_0001", "32'h1_0000", "32'hffff"),  # down add
    ("32'hfffe", "32'hffff", "32'h1_0000"),  # up add
    ("32'hfffe_ffff", "32'h1_0000", "32'hffff"),  # down sub
    ("32'hffff_0002", "32'hffff", "32'h1_0000"),  # up sub
    ("32'd16", "32'hffff_0000", "32'hfffe_ffff"),  # down sl
    ("32'd1", "32'hffff", "32'h1_0000"),  # up sl
    ("32'd16", "32'h1_0000", "32'hffff"),  # (down sr
    ("32'd16", "32'hffff", "32'h1_0000"),  # (up sr
]

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, "pcnt32_carry.v")
    full_code = ""
    code = ""
    cnt = 0
    for mode in modes:
        for i in range(2):
            posy, posz = divmod(cnt, 3)
            (ld_val, m0_val, m1_val) = load_value[cnt]
            code += template.format(
                load_val=ld_val,
                match0_ref=m0_val,
                match1_ref=m1_val,
                pcnt_index=cnt,
                pcnt_mode=mode,
                Y_POS=posy + 1,
                Z_POS=posz + 1,
            )
            cnt += 1

    full_code += head
    full_code += code
    full_code += "endmodule"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(full_code)
