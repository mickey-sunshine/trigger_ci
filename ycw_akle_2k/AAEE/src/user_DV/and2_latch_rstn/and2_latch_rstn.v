
module and2_latch_rstn (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire a,
    input  wire b,
    output wire c,
    output reg  d
);

    assign c = a & b;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            d <= 1'b0;
        end else begin
            d <= c;
        end
    end

endmodule
