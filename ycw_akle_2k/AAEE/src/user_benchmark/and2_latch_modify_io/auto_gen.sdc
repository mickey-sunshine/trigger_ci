create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {a b}]
set_input_delay -clock clk_i -min 0 [get_ports {a b}]

set_output_delay -clock clk_i -max 0 [get_ports {c d}]
set_output_delay -clock clk_i -min 0 [get_ports {c d}]
