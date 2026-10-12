module many_io #(
    parameter DATA_WIDTH = 60
) (
    input  wire                  clk_i,     // 时钟信号
    input  wire                  rst_ni,    // 低电平复位
    input  wire [DATA_WIDTH-1:0] input1_i,
    output reg  [DATA_WIDTH-1:0] output1_o
);
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            output1_o <= {DATA_WIDTH{1'b0}};
        end else begin
            output1_o <= input1_i;
        end
    end

endmodule
