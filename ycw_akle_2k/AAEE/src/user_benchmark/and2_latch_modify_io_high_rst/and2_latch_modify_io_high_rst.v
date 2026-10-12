
module and2_latch_modify_io_high_rst (
    input  wire clk_i,
    input  wire rst_i,
    input  wire a,
    input  wire b,
    output wire c,
    output reg  d
);

    assign c = a & b;
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            d <= 1'b0;
        end else begin
            d <= c;
        end
    end

endmodule
