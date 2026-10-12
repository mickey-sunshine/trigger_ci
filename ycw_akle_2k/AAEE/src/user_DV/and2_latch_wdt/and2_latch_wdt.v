
module and2_latch_wdt (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire a_i,
    input  wire b_i,
    output wire c_o,
    output reg  d_o,
    output wire d_dog_o  // feed wdt
);

    assign c_o = a_i & b_i;
    assign d_dog_o = d_o;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            d_o <= 1'b0;
        end else begin
            d_o <= c_o;
        end
    end

endmodule
