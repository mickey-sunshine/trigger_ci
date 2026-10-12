module sr_fsm (
    input  wire clk,
    input  wire rst_n,
    input  wire E0,
    input  wire E1,
    output wire S0
);
    localparam IDLE = 1'b0;
    localparam TRIGGER = 1'b1;

    reg state_c, state_n;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_c <= IDLE;
        end else begin
            state_c <= state_n;
        end
    end

    always @(E0 or E1) begin
        case (state_c)
            IDLE: begin
                if (E0) begin
                    state_n = TRIGGER;
                end else begin
                    state_n = IDLE;
                end
            end
            TRIGGER: begin
                if (E1) begin
                    state_n = IDLE;
                end else begin
                    state_n = TRIGGER;
                end
            end
            default: state_n = IDLE;
        endcase
    end

    assign S0 = (state_c == TRIGGER) ? 1'b1 : 1'b0;

endmodule
