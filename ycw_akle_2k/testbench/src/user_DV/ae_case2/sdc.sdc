create_clock -period 4.5 -waveform {0 2.25} clk_i
set_clock_latency -source 1.0 [get_clocks {clk_i}]
set_clock_uncertainty 0.03

set_input_delay -clock clk_i -max 2 [get_ports {pwm_i[*]}]
set_input_delay -clock clk_i -min 0 [get_ports {pwm_i[*]}]

set_output_delay -clock clk_i -max 2 [get_ports {pwm_o[*]}]
set_output_delay -clock clk_i -min 0 [get_ports {pwm_o[*]}]
