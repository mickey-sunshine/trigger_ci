create_clock -period 5 -waveform {0 2.5} clk1_i
create_clock -period 5 -waveform {0 2.5} clk2_i

set_input_delay -clock clk1_i -max 0 [get_ports {a_i b_i}]
set_input_delay -clock clk1_i -min 0 [get_ports {a_i b_i}]

set_output_delay -clock clk1_i -max 0 [get_ports {c_o d_o pcnt_o}]
set_output_delay -clock clk1_i -min 0 [get_ports {c_o d_o pcnt_o}]
