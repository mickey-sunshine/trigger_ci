module baud_rate_generator #(
    parameter CLOCK_FREQ = 100000000,  // 100 MHz default clock
    parameter BAUD_RATE  = 9600        // 9600 bps default baud rate
) (
    input  wire clk,       // Input clock
    input  wire reset_n,   // Active low reset
    output reg  baud_tick  // Tick at baud rate
);

    // Calculate the counter limit based on clock frequency and baud rate
    // For a standard 16x oversampling
    localparam integer BAUD_DIVISOR = CLOCK_FREQ / (BAUD_RATE * 16);
    localparam integer COUNTER_WIDTH = $clog2(BAUD_DIVISOR);

    // Counter to generate baud rate
    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter   <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == BAUD_DIVISOR - 1) begin
                counter   <= 0;
                baud_tick <= 1;
            end else begin
                counter   <= counter + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule
