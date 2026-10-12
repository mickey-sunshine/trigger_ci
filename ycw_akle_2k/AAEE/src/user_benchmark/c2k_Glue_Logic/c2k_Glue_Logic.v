
module c2k_Glue_Logic (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire in1_i,
    input  wire in2_i,
    input  wire in3_i,
    output wire out_o
);

    reg  [3:0] count;
    wire       match;
    reg        in1_d1;
    wire       in1_rising;
    // edge detect
    assign in1_rising = in1_i & (~in1_d1);
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            in1_d1 <= 1'b0;
        end else begin
            in1_d1 <= in1_i;
        end
    end

    // counter
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            count <= 4'h0;
        end else begin
            if (count >= 4'ha) begin
                count <= 4'h0;
            end else if (in1_rising == 1'b1) begin
                count <= count + 4'h1;
            end else begin
                count <= count;
            end
        end
    end

    // select output
    assign match = (count >= 4'h7) ? 1'b1 : 1'b0;
    assign out_o = (in3_i == 1'b1) ? in3_i : (match == 1'b1) ? in2_i : in1_i;

endmodule

// module c2k_Glue_Logic (
//     input  wire clk_i,
//     input  wire rst_ni,
//     input  wire in1_i,
//     input  wire in2_i,
//     input  wire in3_i,
//     output reg  out_o
// );

//     wire       enable;
//     wire       match1;
//     wire       match2;
//     wire       reset;
//     wire       in4;
//     reg        temp;
//     reg        select2;
//     reg  [3:0] count;

//     // Combinational logic
//     assign enable = (~in1_i) & temp;
//     assign match1 = (count == 4'h7) ? 1'b1 : 1'b0;
//     assign match2 = (count == 4'h3) ? 1'b1 : 1'b0;
//     assign in4 = (select2 == 1'b1) ? in2_i : in1_i;
//     assign reset = (match1 & ~select2) | (match2 & select2);

//     // Process reg1
//     always @(posedge clk_i or negedge rst_ni) begin
//         if (!rst_ni) begin
//             count <= 4'b0000;
//         end else begin
//             if (reset == 1'b1) count <= 4'b0000;
//             else if (enable == 1'b1) count <= count + 1'b1;
//         end
//     end

//     // Process reg2
//     always @(posedge clk_i or negedge rst_ni) begin
//         if (!rst_ni) begin
//             temp <= 1'b0;
//             select2 <= 1'b0;
//             out_o <= 1'b0;
//         end else begin
//             select2 <= (reset & ~select2) | ((~reset) & select2);
//             temp <= in1_i;
//             out_o <= in4 | in3_i;
//         end
//     end

// endmodule
