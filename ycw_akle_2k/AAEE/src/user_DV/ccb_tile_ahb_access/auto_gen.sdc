create_clock -period 5 -waveform {0 2.5} clk_i
create_clock -period 5 -waveform {0 2.5} clk_ccb_i

set_input_delay -clock clk_i -max 0 [get_ports {event_trig_i[0] event_trig_i[1] event_trig_i[2] event_trig_i[3] event_trig_i[4] event_trig_i[5]}]
set_input_delay -clock clk_i -min 0 [get_ports {event_trig_i[0] event_trig_i[1] event_trig_i[2] event_trig_i[3] event_trig_i[4] event_trig_i[5]}]

set_output_delay -clock clk_i -max 0 [get_ports {pwm_o[0] pwm_o[1] pwm_o[2] pwm_o[3] pwm_o[4] pwm_o[5] pwm_o[6] pwm_o[7] pwm_o[8] pwm_o[9] pwm_o[10] pwm_o[11] pwm_o[12] pwm_o[13] pwm_o[14] pwm_o[15] pwm_o[16] pwm_o[17]}]
set_output_delay -clock clk_i -min 0 [get_ports {pwm_o[0] pwm_o[1] pwm_o[2] pwm_o[3] pwm_o[4] pwm_o[5] pwm_o[6] pwm_o[7] pwm_o[8] pwm_o[9] pwm_o[10] pwm_o[11] pwm_o[12] pwm_o[13] pwm_o[14] pwm_o[15] pwm_o[16] pwm_o[17]}]
