# Application Variables
# Global paths
set search_path "*"
set link_path "*"
# Local Variables
# Read technology files
# Read design files
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/top_ram9k_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/left_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/left_bottom_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/top_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/top_right_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/left_top_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/top_dsp_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/right_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/bottom_ram9k_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/fpga_top_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/bottom_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/grid_dsp_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/grid_ram9k_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/right_bottom_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/bottom_dsp_tile_icv_in_design.pt.v.gz
read_verilog /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/netlist/tile_icv_in_design.pt.v.gz
link_design fpga_top
# Apply the following units
set_units -time ns
# Read RC parasitic files
# Read SDC files
source /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/sdc/disable_timing.tcl
source /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/sdc/enable_cbx_routing_timing.tcl
# Update timing
update_timing
# Switch to design: fpga_top
current_design fpga_top
# Write SDF to file
# Create directories if not exist
file mkdir /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/reports
write_sdf /home/yhjiang/work_space/20260429_issue161/ptpx_utils/tests/tasks/test_alkaid_v0p5_timing_current_design_support/reports/fpga_top.sdf
exit
