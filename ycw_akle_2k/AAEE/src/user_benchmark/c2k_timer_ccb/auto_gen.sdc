create_clock -period 5 -waveform {0 2.5} clk_i

set_input_delay -clock clk_i -max 0 [get_ports {event_trig_i[0] event_trig_i[1] counter_en_i direction_i}]
set_input_delay -clock clk_i -min 0 [get_ports {event_trig_i[0] event_trig_i[1] counter_en_i direction_i}]

set_output_delay -clock clk_i -max 0 [get_ports {interrupt_o gpio_o}]
set_output_delay -clock clk_i -min 0 [get_ports {interrupt_o gpio_o}]
