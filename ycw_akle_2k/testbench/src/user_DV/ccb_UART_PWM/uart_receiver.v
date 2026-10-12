module uart_receiver (
    input  wire       clk,        // Clock input
    input  wire       reset_n,    // Active low reset
    input  wire       baud_tick,  // Tick at 16x baud rate
    input  wire       rx,         // Serial input
    output reg        rx_done,    // Reception complete flag
    output reg  [7:0] rx_data     // Received data
);

    // State definitions
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    reg [1:0] state;
    reg [3:0] tick_count;
    reg [2:0] bit_count;
    reg [7:0] data_reg;
    reg rx_sync, rx_filtered;  // For synchronization and filtering

    // Synchronize rx input to prevent metastability
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_sync <= 1'b0;
            rx_filtered <= 1'b0;
        end else begin
            rx_sync <= rx;
            rx_filtered <= rx_sync;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            tick_count <= 0;
            bit_count <= 0;
            data_reg <= 0;
            rx_done <= 0;
            rx_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    tick_count <= 0;
                    bit_count <= 0;

                    // Detect start bit (falling edge)
                    if (rx_filtered == 0) begin
                        state <= START;
                    end
                end

                START: begin
                    // Sample in the middle of start bit
                    if (baud_tick) begin
                        if (tick_count == 7) begin
                            // Confirm it's still low in the middle of start bit
                            if (rx_filtered == 0) begin
                                tick_count <= 0;
                                state <= DATA;
                            end else begin
                                // False start bit
                                state <= IDLE;
                            end
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        if (tick_count == 15) begin
                            // Sample in the middle of data bit
                            tick_count <= 0;
                            data_reg <= {
                                rx_filtered, data_reg[7:1]
                            };  // Shift right and add new bit

                            if (bit_count == 7) begin
                                bit_count <= 0;
                                state <= STOP;
                            end else begin
                                bit_count <= bit_count + 1;
                            end
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        if (tick_count == 15) begin
                            // Check for valid stop bit
                            if (rx_filtered == 1) begin
                                rx_data <= data_reg;
                                rx_done <= 1;
                            end
                            state <= IDLE;
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
