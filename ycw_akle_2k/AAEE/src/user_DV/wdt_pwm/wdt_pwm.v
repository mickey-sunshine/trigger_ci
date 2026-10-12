
module wdt_pwm (
    input wire clk_i,
    input wire rst_ni,
    input wire [1:0] sel_i,
    output wire d_dog_o  // feed wdt
);

    localparam CNT0_LOAD_VAL = 32'd0;
    localparam CNT0_MATCH0_REF = 32'd50;
    localparam CNT0_MATCH1_REF = 32'd300;
    localparam CNT1_LOAD_VAL = 32'd0;
    localparam CNT1_MATCH0_REF = 32'd100;
    localparam CNT1_MATCH1_REF = 32'd300;
    localparam CNT2_LOAD_VAL = 32'd0;
    localparam CNT2_MATCH0_REF = 32'd250;
    localparam CNT2_MATCH1_REF = 32'd300;
    wire [2:0] zero;
    wire [2:0] match0;
    wire [2:0] match1;
    reg pwm0;
    reg pwm1;
    reg pwm2;
    assign d_dog_o = sel_i == 2'd0 ? pwm0 : (sel_i == 2'd1 ? pwm1 : (sel_i == 2'd2 ? pwm2 : 1'b0));
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm0 <= 1'b0;
        end else begin
            if (match0[0]) pwm0 <= 1'b1;
            else if (zero[0]) pwm0 <= 1'b0;
            else pwm0 <= pwm0;
        end
    end
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm1 <= 1'b0;
        end else begin
            if (match0[1]) pwm1 <= 1'b1;
            else if (zero[1]) pwm1 <= 1'b0;
            else pwm1 <= pwm1;
        end
    end
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm2 <= 1'b0;
        end else begin
            if (match0[2]) pwm2 <= 1'b1;
            else if (zero[2]) pwm2 <= 1'b0;
            else pwm2 <= pwm2;
        end
    end


    pcounter32_clkp_arstn_load #(
        .LOAD_VAL  (CNT0_LOAD_VAL),
        .MATCH0_REF(CNT0_MATCH0_REF),
        .MATCH1_REF(CNT0_MATCH1_REF)
    ) pcnt0_clkp_arstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(match1[0]),
        .enable_i(1'b1),
        .match0_o(match0[0]),
        .match1_o(match1[0]),
        .zero_o(zero[0])
    );

    pcounter32_clkp_arstn_load #(
        .LOAD_VAL  (CNT1_LOAD_VAL),
        .MATCH0_REF(CNT1_MATCH0_REF),
        .MATCH1_REF(CNT1_MATCH1_REF)
    ) pcnt1_clkp_arstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(match1[1]),
        .enable_i(1'b1),
        .match0_o(match0[1]),
        .match1_o(match1[1]),
        .zero_o(zero[1])
    );
    pcounter32_clkp_arstn_load #(
        .LOAD_VAL  (CNT2_LOAD_VAL),
        .MATCH0_REF(CNT2_MATCH0_REF),
        .MATCH1_REF(CNT2_MATCH1_REF)
    ) pcnt2_clkp_arstn (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b0),
        .event_i(match1[2]),
        .enable_i(1'b1),
        .match0_o(match0[2]),
        .match1_o(match1[2]),
        .zero_o(zero[2])
    );

endmodule
