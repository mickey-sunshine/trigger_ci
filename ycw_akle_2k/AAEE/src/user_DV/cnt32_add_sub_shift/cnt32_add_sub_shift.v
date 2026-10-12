
module cnt32_add_sub_shift (
    input  wire       clk_i,
    input  wire       rst_ni,
    input  wire [3:0] event_trig_i,  // 触发pcnt的event   0: add, 1: sub, 2: sr, 3: sl
    input  wire [3:0] enable_i,      // 触发pcnt的计数使能
    output wire [3:0] match_o
);
    localparam LOAD_ADD = 32'd25;  // add 25 when trig event
    localparam MATCH0_ADD = 32'd99;
    localparam MATCH1_ADD = 32'd100;
    localparam LOAD_SUB = 32'd25;  // sub 25 when trig event
    localparam MATCH0_SUB = 32'd49;
    localparam MATCH1_SUB = 32'd50;
    localparam LOAD_SR = 32'd2;  // divide 4 (shift right 2 bit ) when trig event
    localparam MATCH0_SR = 32'd99;
    localparam MATCH1_SR = 32'd100;
    localparam LOAD_SL = 32'd2;  // multiply 4 (shift left 2 bit ) when trig event
    localparam MATCH0_SL = 32'd299;
    localparam MATCH1_SL = 32'd300;

    reg [3:0] event_trig_reg_d1;
    reg [3:0] event_trig_reg_d2;
    reg [3:0] event_trig_reg_d3;
    reg [3:0] event_trig_reg_d4;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            event_trig_reg_d1 <= 4'd0;
            event_trig_reg_d2 <= 4'd0;
            event_trig_reg_d3 <= 4'd0;
            event_trig_reg_d4 <= 4'd0;
        end else begin
            event_trig_reg_d1 <= event_trig_i;
            event_trig_reg_d2 <= event_trig_reg_d1;
            event_trig_reg_d3 <= event_trig_reg_d2;
            event_trig_reg_d4 <= event_trig_reg_d3;
        end
    end

    wire [3:0] match_trig;
    wire rst_add_sub_shift;

    assign rst_add_sub_shift = rst_ni & (~match_trig[0]) & (~match_trig[1]) & (~match_trig[2]) & (~match_trig[3]);
    pcounter32_clkp_arstn_add #(
        .LOAD_VAL  (LOAD_ADD),
        .MATCH0_REF(MATCH0_ADD),
        .MATCH1_REF(MATCH1_ADD)
    ) pcnt0_clkp_arstn (
        .clk_i(clk_i),
        .rst_i(rst_add_sub_shift),
        .up_down_i(1'b0),
        .event_i(event_trig_reg_d4[0] | match_trig[0]),
        .enable_i(enable_i[0]),
        .match0_o(match_o[0]),
        .match1_o(match_trig[0]),
        .zero_o()
    );

    pcounter32_clkp_arstn_sub #(
        .LOAD_VAL  (LOAD_SUB),
        .MATCH0_REF(MATCH0_SUB),
        .MATCH1_REF(MATCH1_SUB)
    ) pcnt1_clkn_arstn (
        .clk_i(clk_i),
        .rst_i(rst_add_sub_shift),
        .up_down_i(1'b0),
        .event_i(event_trig_reg_d4[1] | match_trig[1]),
        .enable_i(enable_i[1]),
        .match0_o(match_o[1]),
        .match1_o(match_trig[1]),
        .zero_o()
    );
    pcounter32_clkp_arstn_sr #(
        .LOAD_VAL  (LOAD_SR),
        .MATCH0_REF(MATCH0_SR),
        .MATCH1_REF(MATCH1_SR)
    ) pcnt2_clkp_srstn (
        .clk_i(clk_i),
        .rst_i(rst_add_sub_shift),
        .up_down_i(1'b0),
        .event_i(event_trig_reg_d4[2] | match_trig[2]),
        .enable_i(enable_i[2]),
        .match0_o(match_o[2]),
        .match1_o(match_trig[2]),
        .zero_o()
    );
    pcounter32_clkp_arstn_sl #(
        .LOAD_VAL  (LOAD_SL),
        .MATCH0_REF(MATCH0_SL),
        .MATCH1_REF(MATCH1_SL)
    ) pcnt3_clkn_srstn (
        .clk_i(clk_i),
        .rst_i(rst_add_sub_shift),
        .up_down_i(1'b0),
        .event_i(event_trig_reg_d4[3] | match_trig[3]),
        .enable_i(enable_i[3]),
        .match0_o(match_o[3]),
        .match1_o(match_trig[3]),
        .zero_o()
    );


endmodule
