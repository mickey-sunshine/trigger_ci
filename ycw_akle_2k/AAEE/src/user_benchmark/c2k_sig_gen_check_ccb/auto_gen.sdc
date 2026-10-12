create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {pwm_sel_i pwm_err_i event_ccb_i[0] event_ccb_i[1] event_ccb_i[2] event_ccb_i[3]}]
set_input_delay -clock clk_i -min 0 [get_ports {pwm_sel_i pwm_err_i event_ccb_i[0] event_ccb_i[1] event_ccb_i[2] event_ccb_i[3]}]

set_output_delay -clock clk_i -max 0 [get_ports {pwm_out_o interrupt1_o interrupt2_o}]
set_output_delay -clock clk_i -min 0 [get_ports {pwm_out_o interrupt1_o interrupt2_o}]
