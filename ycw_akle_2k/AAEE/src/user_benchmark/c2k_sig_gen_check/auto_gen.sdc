create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {pwm_sel_i pwm_err_i}]
set_input_delay -clock clk_i -min 0 [get_ports {pwm_sel_i pwm_err_i}]

set_output_delay -clock clk_i -max 0 [get_ports {pwm_out_o interrupt1_o interrupt2_o}]
set_output_delay -clock clk_i -min 0 [get_ports {pwm_out_o interrupt1_o interrupt2_o}]
