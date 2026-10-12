create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {e0 e1}]
set_input_delay -clock clk_i -min 0 [get_ports {e0 e1}]

set_output_delay -clock clk_i -max 0 [get_ports {pwm_opening pwm_closing state[0] state[1]}]
set_output_delay -clock clk_i -min 0 [get_ports {pwm_opening pwm_closing state[0] state[1]}]
