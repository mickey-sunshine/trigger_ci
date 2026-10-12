module edge_detection (
    input       clk_i,
    input       rst_ni,
    input       signal_i,
    output wire edge_p_trig_o,
    output wire edge_n_trig_o
);

    reg [1:0] signal_sync_q;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_sync_q <= 2'b00;
        end else begin
            signal_sync_q <= {signal_sync_q[0], signal_i};
        end
    end

    assign edge_p_trig_o = ~signal_sync_q[1] & signal_sync_q[0];
    assign edge_n_trig_o = signal_sync_q[1] & ~signal_sync_q[0];

endmodule
