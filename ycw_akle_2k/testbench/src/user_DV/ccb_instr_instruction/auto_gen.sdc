create_clock -period 5 -waveform {0 2.5} clk_i
create_clock -period 5 -waveform {0 2.5} clk_ccb_i

set_input_delay -clock clk_i -max 0 [get_ports {event_trig_i[0] event_trig_i[1] event_trig_i[2] event_trig_i[3]}]
set_input_delay -clock clk_i -min 0 [get_ports {event_trig_i[0] event_trig_i[1] event_trig_i[2] event_trig_i[3]}]

set_output_delay -clock clk_i -max 0 [get_ports {pwm_o}]
set_output_delay -clock clk_i -min 0 [get_ports {pwm_o}]
