module clb_high_lut_usage #(
    parameter N = 5  // 生成器数量，可调
    // parameter N = 6  // 布不通
) (
    input  wire           clk_i,
    input  wire           rst_ni,
    input  wire           start,
    output wire [N-1 : 0] sum_out
);

    // 存放每个LFSR的输出
    wire [15:0] rand_out[N-1:0];

    // 使用 generate 生成 N 个 16 位随机数生成器
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : GEN_LFSR
            lfsr16 u_lfsr16 (
                .clk_i(clk_i),
                .rst_ni(rst_ni),
                .start(start),
                .seed(i),
                .random_out(rand_out[i])
            );
            assign sum_out[i] = rand_out[i][0];
        end
    endgenerate
endmodule



module lfsr16 (
    input wire clk_i,
    input wire rst_ni,
    input wire start,
    input wire [15:0] seed,
    output reg [15:0] random_out
);
    reg [15:0] lfsr;
    wire feedback = lfsr[15] ^ lfsr[4] ^ lfsr[2] ^ lfsr[1]; // 多项式 x^16 + x^14 + x^13 + x^11 + 1

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) lfsr <= seed;  // 初始种子
        else if (start) lfsr <= {lfsr[14:0], feedback} + 1;
        else lfsr <= lfsr;
    end

    always @(*) begin
        random_out = lfsr;
    end
endmodule
