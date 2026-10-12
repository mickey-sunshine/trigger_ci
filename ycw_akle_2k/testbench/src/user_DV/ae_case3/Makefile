# Makefile

# defaults
SIM ?= icarus
BENCHMARK_RTL_SIM ?= ON

# include vcs setup for the tests
include ${MAKEFILE_INC_HOME}/makefile_vcs.inc

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ${CELL_LIB_HOME}/ccb_inst_code.v
VERILOG_SOURCES += ${CELL_LIB_HOME}/cell_sim_ccb2.v
VERILOG_SOURCES += ${CELL_LIB_HOME}/cell_sim_pcnt.v
VERILOG_SOURCES += sig_off_g1p6.v 
VERILOG_SOURCES += ae_case3_off_pwm_sel.v 
VERILOG_SOURCES += ae_case3_off_pwm_mode_ctrl.v 
VERILOG_SOURCES += ae_case3_off_pwm_ctrl.v 
VERILOG_SOURCES += ae_case3_edge_detection.v 
VERILOG_SOURCES += ae_case3.v 

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ae_case3

# Enable the flag just for simulation purpose
ifeq ($(BENCHMARK_RTL_SIM),ON)
ifeq (${SIM},icarus)
COMPILE_ARGS += -DFULL_CCB_MODEL_FOR_SIM=1
endif
endif

# Extra options
COCOTB_PLUSARGS += +define+UNIT_DELAY
# Enable the flag just for simulation purpose
ifeq ($(BENCHMARK_RTL_SIM),ON)
COCOTB_PLUSARGS += +define+FULL_CCB_MODEL_FOR_SIM
endif

# COCOTB_TEST_MODULES is the basename of the Python test file
COCOTB_TEST_MODULES   ?= test_ae_case3


include $(shell cocotb-config --makefiles)/Makefile.sim

