module uart_top #(
    parameter CLOCK_FREQ = 100000000,  // 100 MHz default
    parameter BAUD_RATE  = 9600        // 9600 bps default
) (
    input wire clk,     // System clock
    input wire reset_n, // Active low reset

    // UART interface
    input  wire rx,  // UART RX
    output wire tx,  // UART TX

    // User interface
    input  wire [7:0] tx_data,   // Data to transmit
    input  wire       tx_start,  // Start transmission
    output wire       tx_busy,   // Transmitter busy

    output wire [7:0] rx_data,  // Received data
    output wire       rx_done   // Data received flag
);

    // Internal signals
    wire baud_tick;

    // Instantiate baud rate generator
    baud_rate_generator #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) baud_gen (
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick)
    );

    // Instantiate transmitter
    uart_transmitter tx_module (
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx)
    );

    // Instantiate receiver
    uart_receiver rx_module (
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick),
        .rx(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

endmodule
