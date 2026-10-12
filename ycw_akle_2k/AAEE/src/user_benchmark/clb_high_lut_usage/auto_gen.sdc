create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {start}]
set_input_delay -clock clk_i -min 0 [get_ports {start}]

set_output_delay -clock clk_i -max 0 [get_ports {sum_out[0] sum_out[1] sum_out[2] sum_out[3] sum_out[4]}]
set_output_delay -clock clk_i -min 0 [get_ports {sum_out[0] sum_out[1] sum_out[2] sum_out[3] sum_out[4]}]
