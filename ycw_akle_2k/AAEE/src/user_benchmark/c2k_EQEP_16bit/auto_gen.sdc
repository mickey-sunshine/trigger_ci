create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {EQEP_A_i EQEP_B_i EQEP_I_i}]
set_input_delay -clock clk_i -min 0 [get_ports {EQEP_A_i EQEP_B_i EQEP_I_i}]

set_output_delay -clock clk_i -max 0 [get_ports {wdt_o dir_o error_o counter_o qclk_o}]
set_output_delay -clock clk_i -min 0 [get_ports {wdt_o dir_o error_o counter_o qclk_o}]
