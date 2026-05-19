# Application Variables
# Global paths
set search_path "* /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp30p140lvt_100d /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp30p140hvt_100d /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp30p140mbhvt_100d /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp7t30p140lvt_100d /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp7t30p140hvt_100d /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp7t30p140mbhvt_100d"
set link_path "* tcbn22ulpbwp30p140lvttt0p9v25c.db tcbn22ulpbwp30p140hvttt0p9v25c.db tcbn22ulpbwp30p140mbhvttt0p9v25c.db tcbn22ulpbwp7t30p140lvttt0p9v25c.db tcbn22ulpbwp7t30p140hvttt0p9v25c.db tcbn22ulpbwp7t30p140mbhvttt0p9v25c.db"
# Local Variables
# Read technology files
read_db /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp30p140lvt_100d/tcbn22ulpbwp30p140lvttt0p9v25c.db
read_db /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp30p140hvt_100d/tcbn22ulpbwp30p140hvttt0p9v25c.db
read_db /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp30p140mbhvt_100d/tcbn22ulpbwp30p140mbhvttt0p9v25c.db
read_db /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp7t30p140lvt_100d/tcbn22ulpbwp7t30p140lvttt0p9v25c.db
read_db /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp7t30p140hvt_100d/tcbn22ulpbwp7t30p140hvttt0p9v25c.db
read_db /home/yhjiang/work_space/20260429_issue161/ptpx_utils/pdk/t22/tsmc22ulp/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn22ulpbwp7t30p140mbhvt_100d/tcbn22ulpbwp7t30p140mbhvttt0p9v25c.db
# Read design files
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/top_ram9k_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/left_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/left_bottom_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/top_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/top_right_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/left_top_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/top_dsp_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/right_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/bottom_ram9k_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/fpga_top_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/bottom_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/grid_dsp_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/grid_ram9k_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/right_bottom_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/bottom_dsp_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/netlist/tile_icv_in_design.pt.v.gz
link_design fpga_top
# Apply the following units
set_units -time ns
# Read RC parasitic files
read_parasitics -keep_capacitive_coupling /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/fpga_top/fpga_top.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == top_right_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/top_right_tile/top_right_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == grid_ram9k_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/grid_ram9k_tile/grid_ram9k_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == top_dsp_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/top_dsp_tile/top_dsp_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/tile/tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == left_bottom_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/left_bottom_tile/left_bottom_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == right_bottom_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/right_bottom_tile/right_bottom_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == grid_dsp_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/grid_dsp_tile/grid_dsp_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == top_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/top_tile/top_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == right_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/right_tile/right_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == bottom_dsp_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/bottom_dsp_tile/bottom_dsp_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == top_ram9k_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/top_ram9k_tile/top_ram9k_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == bottom_ram9k_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/bottom_ram9k_tile/bottom_ram9k_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == bottom_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/bottom_tile/bottom_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == left_top_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/left_top_tile/left_top_tile.rcw_0c.spef.gz
read_parasitics -keep_capacitive_coupling -path [get_cells "*/*" -filter "ref_name == left_tile"] /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/spef/left_tile/left_tile.rcw_0c.spef.gz
# Read SDC files
source /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/sdc/disable_timing.tcl
source /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/sdc/enable_cbx_routing_timing.tcl
# Update timing
update_timing
# Switch to design: fpga_top
current_design fpga_top
# Write SDF to file
# Create directories if not exist
file mkdir /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/reports
write_sdf /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/alkaid_v0p5_timing_current_design_support/reports/fpga_top.sdf
exit
