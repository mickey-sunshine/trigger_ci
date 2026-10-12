//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/28 15:47:46
// Design Name: 
// Module Name: edge_detection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ae_case3_edge_detection (
    input clk_i,
    input rst_ni,

    input signal_i,

    output edge_p_trig_o,
    output edge_n_trig_o
);

    reg signal_1p_r, signal_2p_r;
    // Registered edge outputs to break combinational path (timing optimization)
    reg edge_p_r, edge_n_r;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            signal_1p_r <= 1'b0;
            signal_2p_r <= 1'b0;
        end else begin
            signal_1p_r <= signal_i;
            signal_2p_r <= signal_1p_r;
        end
    end
    // compute edges and register them to shorten downstream timing paths
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            edge_p_r <= 1'b0;
            edge_n_r <= 1'b0;
        end else begin
            edge_p_r <= (~signal_2p_r) & signal_1p_r;
            edge_n_r <= signal_2p_r & (~signal_1p_r);
        end
    end

    assign edge_p_trig_o = edge_p_r;
    assign edge_n_trig_o = edge_n_r;
endmodule
