// -----------------------------------------------------------------------------
// bench_carry_add
// Carry-chain stress. A single wide add exposes the longest carry path, and a
// feedback accumulator adds a register-to-register carry loop. Inputs and outputs
// are registered so the measured path is purely the adder. Sweep WIDTH to find
// where the fabric carry logic stops scaling linearly.
// -----------------------------------------------------------------------------
`default_nettype none

module bench_carry_add #(
    parameter integer WIDTH = 32
) (
    input  wire             clk_i,
    input  wire             rst_ni,
    input  wire             en_i,
    input  wire [WIDTH-1:0] a_i,
    input  wire [WIDTH-1:0] b_i,
    output wire [WIDTH-1:0] sum_o,
    output wire [WIDTH-1:0] acc_o
);

    reg [WIDTH-1:0] a_r;
    reg [WIDTH-1:0] b_r;
    reg [WIDTH-1:0] sum_r;
    reg [WIDTH-1:0] acc_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            a_r   <= {WIDTH{1'b0}};
            b_r   <= {WIDTH{1'b0}};
            sum_r <= {WIDTH{1'b0}};
            acc_r <= {WIDTH{1'b0}};
        end else if (en_i) begin
            a_r   <= a_i;
            b_r   <= b_i;
            sum_r <= a_r + b_r;  // longest single carry path
            acc_r <= acc_r + a_r;  // carry path inside a feedback loop
        end
    end

    assign sum_o = sum_r;
    assign acc_o = acc_r;

endmodule

`default_nettype wire
