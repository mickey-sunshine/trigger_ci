///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File name: rf_pulse_gen.v
// Descriptions: This module is used to generate the pulse according to the input rising edge.
// Author: Yihong
// Date: 2025/7/16
// Revision: 0.0.1
// Revision History:
// V0.0.1 - 2025/7/16 initial release
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module rf_pulse_gen (
    input  clk_i,     // system clock
    input  rst_ni,    // system reset, active low
    input  signal_i,  // input signal to trigger the pulse
    output pulse_o    // output pulse signal
);

    // ---------- Internal registers ----------------------
    reg r_signal0;  // signal pipe 0
    reg r_signal1;  // signal pipe 1

    // ---------- Internal wires --------------------------

    // ---------- combination logic -----------------------
    assign pulse_o = r_signal0 & ~r_signal1;  // generate pulse on rising edge of signal_i

    //----------- sequence logic --------------------------
    always @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            r_signal0 <= 1'b0;
            r_signal1 <= 1'b0;
        end else begin
            r_signal0 <= signal_i;
            r_signal1 <= r_signal0;
        end
    end

    //----------- instances of sub modules ----------------



endmodule
