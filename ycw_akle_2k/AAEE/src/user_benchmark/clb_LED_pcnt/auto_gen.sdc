create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {seg_data_i[0] seg_data_i[1] seg_data_i[2] seg_data_i[3] seg_data_i[4] seg_data_i[5] seg_data_i[6] seg_data_i[7] seg_data_i[8] seg_data_i[9] seg_data_i[10] seg_data_i[11] seg_data_i[12] seg_data_i[13] seg_data_i[14] seg_data_i[15]}]
set_input_delay -clock clk_i -min 0 [get_ports {seg_data_i[0] seg_data_i[1] seg_data_i[2] seg_data_i[3] seg_data_i[4] seg_data_i[5] seg_data_i[6] seg_data_i[7] seg_data_i[8] seg_data_i[9] seg_data_i[10] seg_data_i[11] seg_data_i[12] seg_data_i[13] seg_data_i[14] seg_data_i[15]}]

set_output_delay -clock clk_i -max 0 [get_ports {sclk_o rclk_o dio_o}]
set_output_delay -clock clk_i -min 0 [get_ports {sclk_o rclk_o dio_o}]
