module clb_PRBS_32 (
    input  wire        clk_i,      // 时钟信号
    input  wire        rst_ni,     // 低电平复位
    input  wire        enable_i,   // 启用信号
    output reg  [31:0] random_out  // 随机数输出
);

    // 选取的反馈多项式: x^32 + x^7 + x^6 + x^2 + 1
    wire feedback;

    assign feedback = random_out[31] ^ random_out[6] ^ random_out[5] ^ random_out[1];

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) random_out <= 32'h1;  // 初始种子（可改）
        else if (!enable_i) random_out <= random_out;
        else random_out <= {random_out[30:0], feedback};  // 移位并插入反馈
    end

endmodule
