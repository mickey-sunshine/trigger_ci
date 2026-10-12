create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {rx_i}]
set_input_delay -clock clk_i -min 0 [get_ports {rx_i}]

set_output_delay -clock clk_i -max 0 [get_ports {tx_o zero_o[0] zero_o[1] pwm_o event_o}]
set_output_delay -clock clk_i -min 0 [get_ports {tx_o zero_o[0] zero_o[1] pwm_o event_o}]
