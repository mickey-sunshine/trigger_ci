// driver_74HC595
module clb_LED_verilog (
    input wire clk_i,  // System clock
    input wire rst_ni,  // Active high reset
    input wire [15:0] seg_data_i,  //4 data, range is 0-f,{seg_data[3], seg_data[2], seg_data[1], seg_data[0]}
    output reg sclk_o,
    output reg rclk_o,
    output reg dio_o
);
    parameter CLK_DIV = 10;
    // Define the segment patterns for digits 0-9 and letters A-F, -
    wire [7:0] LED[16:0];
    assign LED[0]  = 8'hC0;  // 0
    assign LED[1]  = 8'hF9;  // 1
    assign LED[2]  = 8'hA4;  // 2
    assign LED[3]  = 8'hB0;  // 3
    assign LED[4]  = 8'h99;  // 4
    assign LED[5]  = 8'h92;  // 5
    assign LED[6]  = 8'h82;  // 6
    assign LED[7]  = 8'hF8;  // 7
    assign LED[8]  = 8'h80;  // 8
    assign LED[9]  = 8'h90;  // 9
    assign LED[10] = 8'h88;  // A
    assign LED[11] = 8'h83;  // b
    assign LED[12] = 8'hc6;  // C
    assign LED[13] = 8'ha1;  // d
    assign LED[14] = 8'h86;  // E
    assign LED[15] = 8'h8e;  // F
    assign LED[16] = 8'hbf;  // -


    reg  [ 1:0] seg_sel_cnt;
    wire [ 3:0] sel_cnt_x4;
    wire [ 7:0] seg_sel;
    reg  [ 3:0] seg_bit_cnt;
    reg  [31:0] clk_div;
    wire [15:0] seg_out;  //{seg_data, seg_sel}
    assign seg_out = {LED[seg_data_i[sel_cnt_x4+:4]], seg_sel};
    assign sel_cnt_x4 = seg_sel_cnt << 2;
    assign seg_sel = 1 << seg_sel_cnt;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            clk_div <= 32'h0;
            sclk_o <= 1'b0;
            rclk_o <= 1'b0;
            seg_bit_cnt <= 4'h0;
            seg_sel_cnt <= 2'h0;
        end else begin
            clk_div <= clk_div + 32'h1;
            if (clk_div >= (CLK_DIV - 1)) begin
                if (seg_bit_cnt == 4'hf) begin
                    if (rclk_o == 1'b1) begin
                        seg_bit_cnt <= seg_bit_cnt + 1;
                        seg_sel_cnt <= seg_sel_cnt + 1;
                        rclk_o <= 1'b0;
                    end else begin
                        seg_bit_cnt <= seg_bit_cnt;
                        rclk_o <= 1'b1;
                    end
                    sclk_o <= sclk_o;
                end else begin
                    rclk_o <= 1'b0;
                    sclk_o <= !sclk_o;
                    seg_bit_cnt <= seg_bit_cnt + 1;
                end
                clk_div <= 32'h0;
            end else if (clk_div == ((CLK_DIV >> 1) - 1)) begin
                sclk_o <= !sclk_o;
                seg_bit_cnt <= seg_bit_cnt;
            end else begin
                sclk_o <= sclk_o;
                seg_bit_cnt <= seg_bit_cnt;
            end
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            dio_o <= 1'b0;
        end else begin
            dio_o <= seg_out[15-seg_bit_cnt];
        end
    end

endmodule
