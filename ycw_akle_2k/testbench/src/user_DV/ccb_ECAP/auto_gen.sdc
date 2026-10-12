create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {in1_i in2_i}]
set_input_delay -clock clk_i -min 0 [get_ports {in1_i in2_i}]

set_output_delay -clock clk_i -max 0 [get_ports {event_ccb[0] event_ccb[1] event_ccb[2] event_ccb[3] counter_o[0] counter_o[1]}]
set_output_delay -clock clk_i -min 0 [get_ports {event_ccb[0] event_ccb[1] event_ccb[2] event_ccb[3] counter_o[0] counter_o[1]}]
