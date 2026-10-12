
module local_reset_gen_test (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire in1_i,
    output wire out0_o,
    output wire out1_o,
    output wire out2_o,
    output wire out3_o,
    output wire out4_o,
    output wire out5_o,
    output wire out6_o,
    output wire match0,
    output wire match1,
    output reg  match1_d1
);
    reg [2:0] internal_reg;
    // possible ways to generate a reset signal
    assign out0_o = rst_ni;
    assign out1_o = in1_i;
    assign out2_o = rst_ni & in1_i;
    assign out3_o = rst_ni & internal_reg[2];
    assign out4_o = rst_ni & (~match1);
    assign out5_o = rst_ni & (~match1_d1);
    assign out6_o = out4_o & out5_o;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            internal_reg <= 3'b0;
            match1_d1    <= 1'b0;
        end else begin
            internal_reg <= internal_reg + 1;
            match1_d1    <= match1;
        end
    end

    pcounter32_clkp_arstn_load #(
        .MATCH0_REF(5),
        .MATCH1_REF(10)
    ) pcnt (
        .clk_i    (clk_i),
        .rst_i    (out5_o),
        .up_down_i(1'b0),
        .event_i  (1'b0),
        .enable_i (1'b1),
        .match0_o (match0),
        .match1_o (match1),
        .zero_o   ()
    );
endmodule
