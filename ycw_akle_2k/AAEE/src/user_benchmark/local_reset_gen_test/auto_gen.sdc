create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {in1_i}]
set_input_delay -clock clk_i -min 0 [get_ports {in1_i}]

set_output_delay -clock clk_i -max 0 [get_ports {out0_o out1_o out2_o out3_o out4_o out5_o out6_o match0 match1 match1_d1}]
set_output_delay -clock clk_i -min 0 [get_ports {out0_o out1_o out2_o out3_o out4_o out5_o out6_o match0 match1 match1_d1}]
