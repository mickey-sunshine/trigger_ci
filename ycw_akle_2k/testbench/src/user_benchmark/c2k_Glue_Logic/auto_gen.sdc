create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {in1_i in2_i in3_i}]
set_input_delay -clock clk_i -min 0 [get_ports {in1_i in2_i in3_i}]

set_output_delay -clock clk_i -max 0 [get_ports {out_o}]
set_output_delay -clock clk_i -min 0 [get_ports {out_o}]
