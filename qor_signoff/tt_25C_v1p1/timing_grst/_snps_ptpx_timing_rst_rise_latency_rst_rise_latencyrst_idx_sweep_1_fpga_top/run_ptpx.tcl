# Application Variables
set timing_report_unconstrained_paths true
# Global paths
set search_path "* /eda/internal/alkaid_infra/pdk/s40/s40ulp/std_cell/SCC40ULP_UHDC40_HVT/V0p2/liberty/1.1v /eda/internal/alkaid_infra/pdk/s40/s40ulp/std_cell/SCC40ULP_UHDC40_LVT/V0p2/liberty/1.1v /eda/internal/alkaid_infra/pdk/s40/s40ulp/std_cell/SCC40ULP_UHDC40_RVT_V0p2/liberty/1.1v"
set link_path "* scc40ulp_uhdc40_hvt_tt_v1p1_25c_basic.db scc40ulp_uhdc40_lvt_tt_v1p1_25c_basic.db scc40ulp_uhdc40_rvt_tt_v1p1_25c_basic.db"
# Local Variables
# Read technology files
read_db /eda/internal/alkaid_infra/pdk/s40/s40ulp/std_cell/SCC40ULP_UHDC40_HVT/V0p2/liberty/1.1v/scc40ulp_uhdc40_hvt_tt_v1p1_25c_basic.db
read_db /eda/internal/alkaid_infra/pdk/s40/s40ulp/std_cell/SCC40ULP_UHDC40_LVT/V0p2/liberty/1.1v/scc40ulp_uhdc40_lvt_tt_v1p1_25c_basic.db
read_db /eda/internal/alkaid_infra/pdk/s40/s40ulp/std_cell/SCC40ULP_UHDC40_RVT_V0p2/liberty/1.1v/scc40ulp_uhdc40_rvt_tt_v1p1_25c_basic.db
# Read design files
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/fpga_core.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/fpga_top.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_5_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_3_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_6_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/grid_io_rightL_right.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_2_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_11_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_4_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_3_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_3_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_2_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_4_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_9_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_8_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_7_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/direct_interc.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_4_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/grid_io_bottomL_bottom.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_13_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_2_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_1_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/grid_clb.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_0_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/grid_io_leftL_left.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_1_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_7_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_6_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_0_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/grid_io_topL_top.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_5_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/sb_12_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cby_1_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_0_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/subblock/cbx_5_.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/bottom_right_tile.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/left_bottom_tile.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/left_tile_clock_out.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/tile_sub.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/top_left_tile.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/bottom_tile_right_edge.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/left_tile_sub.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/tile_right_edge_sub.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/tile_right_edge_main.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/left_tile_main.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/left_tile_clock_above.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/tile_main.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/bottom_tile.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/top_tile.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/left_tile_clock_below.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/right_tile_sub.v
read_verilog /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/netlist/tile/right_tile_main.v
link_design fpga_top
# Apply the following units
set_units -time ns
# Read RC parasitic files
# Read SDC files
read_sdc /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/_snps_ptpx_timing_rst_rise_latency_rst_rise_latencyrst_idx_sweep_1_fpga_top/bitstream.sdc
source /home/yhjiang/work_space/20260429_issue161/aaee/etc/device/ALKDL/qor_signoff/timing_gclk/sdc/disable_comb_loops.tcl
source /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/qor_signoff/tt_25C_v1p1/timing_grst/custom_sdc/gclk.tcl
# Report timing to file
set from_pin_group []
set from_pin_group [add_to_collection ${from_pin_group} [get_ports reset[1]]]
set to_pin_group []
set to_pin_group [add_to_collection ${to_pin_group} [get_pins fpga_core*/tile_*__*_/grid_clb*/*fle*/*ff*/*/R*]]
set to_pin_group [add_to_collection ${to_pin_group} [get_pins fpga_core*/tile_*__*_/grid_io*/*/*/*reg*/R*]]
set_max_delay 0 -from ${from_pin_group} -to ${to_pin_group}
set_min_delay 100 -from ${from_pin_group} -to ${to_pin_group}
update_timing
file mkdir /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/reports/ultimate/timing/gl/tt_25C_v1p1/fpga_top
redirect -file "/home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/reports/ultimate/timing/gl/tt_25C_v1p1/fpga_top/rst_rise_latencyrst_idx_sweep_1.rpt" {
	report_timing -from ${from_pin_group} -to ${to_pin_group} -path_type full_clock_expanded -delay_type max -nworst 1 -max_paths 1000 -net -input_pins -significant_digits 6 -nosplit -capacitance -transition_time -include_hierarchical_pins
}
exec /bin/sh -c "sed -i 's/.*Date.*/--removed--/g' /home/yhjiang/work_space/20260429_issue161/aaee/test/tasks/alkaidL/s40/step_run/_work/alkaid_exto/alkaid_ex_netlist/iter0/reports/ultimate/timing/gl/tt_25C_v1p1/fpga_top/rst_rise_latencyrst_idx_sweep_1.rpt"
exit
