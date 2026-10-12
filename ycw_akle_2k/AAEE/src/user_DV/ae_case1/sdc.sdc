create_clock -period 4.5 -waveform {0 2.25} clk_i
set_clock_latency -source 1.0 [get_clocks {clk_i}]
set_clock_uncertainty 0.03

set_input_delay -clock clk_i -max 2 [get_ports {epwm_1a_i epwm_1b_i}]
# The input registers are intentionally packed into the IO cells.  The IO FF
# has a 0.117 ns hold requirement plus 0.03 ns uncertainty, so the external
# source must provide at least 0.15 ns minimum delay.  Use 0.20 ns for margin.
set_input_delay -clock clk_i -min 0.20 [get_ports {epwm_1a_i epwm_1b_i}]

set_output_delay -clock clk_i -max 2 [get_ports {EPWM_2A_o EPWM_2B_o}]
set_output_delay -clock clk_i -min 0 [get_ports {EPWM_2A_o EPWM_2B_o}]
