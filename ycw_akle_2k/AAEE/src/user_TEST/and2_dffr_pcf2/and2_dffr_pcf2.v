/////////////////////////////////////////
//  Functionality: 2-input AND with clocked DFF
//                 and combinational outputs 
//  Author:        Xifan Tang
////////////////////////////////////////



module and2_dffr_pcf2 (
    a,
    b,
    clk,
    rst,
    c,
    d
);

    input wire clk;
    input wire rst;

    input wire a;
    input wire b;
    output wire c;
    output reg d;

    assign c = a & b;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d <= 0;
        end else begin
            d <= c;
        end
    end

endmodule
