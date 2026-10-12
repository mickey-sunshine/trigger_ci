module uart_transmitter (
    input  wire       clk,        // Clock input
    input  wire       reset_n,    // Active low reset
    input  wire       baud_tick,  // Tick at 16x baud rate
    input  wire       tx_start,   // Start transmission
    input  wire [7:0] tx_data,    // Data to transmit
    output reg        tx_busy,    // Transmitter busy flag
    output reg        tx          // Serial output
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

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            tick_count <= 0;
            bit_count <= 0;
            data_reg <= 0;
            tx <= 1;  // Idle line is high
            tx_busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;  // Idle line is high
                    tick_count <= 0;
                    bit_count <= 0;

                    if (tx_start && !tx_busy) begin
                        data_reg <= tx_data;
                        state <= START;
                        tx_busy <= 1;
                    end else begin
                        tx_busy <= 0;
                    end
                end

                START: begin
                    tx <= 0;  // Start bit is low

                    if (baud_tick) begin
                        if (tick_count == 15) begin
                            tick_count <= 0;
                            state <= DATA;
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end

                DATA: begin
                    tx <= data_reg[0];  // LSB first

                    if (baud_tick) begin
                        if (tick_count == 15) begin
                            tick_count <= 0;
                            data_reg   <= {1'b0, data_reg[7:1]};  // Right shift

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
                    tx <= 1;  // Stop bit is high

                    if (baud_tick) begin
                        if (tick_count == 15) begin
                            tick_count <= 0;
                            state <= IDLE;
                            tx_busy <= 0;
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
