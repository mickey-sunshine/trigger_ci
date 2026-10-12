create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {epwm_1a_i epwm_1b_i}]
set_input_delay -clock clk_i -min 0 [get_ports {epwm_1a_i epwm_1b_i}]

set_output_delay -clock clk_i -max 0 [get_ports {EPWM_2A_o EPWM_2B_o}]
set_output_delay -clock clk_i -min 0 [get_ports {EPWM_2A_o EPWM_2B_o}]
