create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {up_down_i[0] up_down_i[1] event_i[0] event_i[1] enable_i[0] enable_i[1]}]
set_input_delay -clock clk_i -min 0 [get_ports {up_down_i[0] up_down_i[1] event_i[0] event_i[1] enable_i[0] enable_i[1]}]

set_output_delay -clock clk_i -max 0 [get_ports {match0_o[0] match0_o[1] match1_o[0] match1_o[1] zero_o[0] zero_o[1]}]
set_output_delay -clock clk_i -min 0 [get_ports {match0_o[0] match0_o[1] match1_o[0] match1_o[1] zero_o[0] zero_o[1]}]
