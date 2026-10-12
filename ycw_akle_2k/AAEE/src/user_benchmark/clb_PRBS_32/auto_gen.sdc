create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {enable_i}]
set_input_delay -clock clk_i -min 0 [get_ports {enable_i}]

set_output_delay -clock clk_i -max 0 [get_ports {random_out[0] random_out[1] random_out[2] random_out[3] random_out[4] random_out[5] random_out[6] random_out[7] random_out[8] random_out[9] random_out[10] random_out[11] random_out[12] random_out[13] random_out[14] random_out[15] random_out[16] random_out[17] random_out[18] random_out[19] random_out[20] random_out[21] random_out[22] random_out[23] random_out[24] random_out[25] random_out[26] random_out[27] random_out[28] random_out[29] random_out[30] random_out[31]}]
set_output_delay -clock clk_i -min 0 [get_ports {random_out[0] random_out[1] random_out[2] random_out[3] random_out[4] random_out[5] random_out[6] random_out[7] random_out[8] random_out[9] random_out[10] random_out[11] random_out[12] random_out[13] random_out[14] random_out[15] random_out[16] random_out[17] random_out[18] random_out[19] random_out[20] random_out[21] random_out[22] random_out[23] random_out[24] random_out[25] random_out[26] random_out[27] random_out[28] random_out[29] random_out[30] random_out[31]}]
