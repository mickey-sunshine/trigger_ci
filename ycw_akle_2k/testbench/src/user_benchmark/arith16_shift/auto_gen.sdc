create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {up_down_i[0] up_down_i[1] up_down_i[2] up_down_i[3] event_i[0] event_i[1] event_i[2] event_i[3] enable_i[0] enable_i[1] enable_i[2] enable_i[3]}]
set_input_delay -clock clk_i -min 0 [get_ports {up_down_i[0] up_down_i[1] up_down_i[2] up_down_i[3] event_i[0] event_i[1] event_i[2] event_i[3] enable_i[0] enable_i[1] enable_i[2] enable_i[3]}]

set_output_delay -clock clk_i -max 0 [get_ports {match0_o[0] match0_o[1] match0_o[2] match0_o[3] match1_o[0] match1_o[1] match1_o[2] match1_o[3] zero_o[0] zero_o[1] zero_o[2] zero_o[3]}]
set_output_delay -clock clk_i -min 0 [get_ports {match0_o[0] match0_o[1] match0_o[2] match0_o[3] match1_o[0] match1_o[1] match1_o[2] match1_o[3] zero_o[0] zero_o[1] zero_o[2] zero_o[3]}]
