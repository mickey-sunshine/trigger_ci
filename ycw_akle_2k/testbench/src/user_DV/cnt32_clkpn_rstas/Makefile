# Makefile

# defaults
SIM ?= icarus

# include vcs setup for the tests
include ${MAKEFILE_INC_HOME}/makefile_vcs.inc

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ${CELL_LIB_HOME}/cell_sim_pcnt.v
VERILOG_SOURCES += cnt32_clkpn_rstas.v 

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = cnt32_clkpn_rstas

# Extra options
COCOTB_PLUSARGS += +define+UNIT_DELAY

# COCOTB_TEST_MODULES is the basename of the Python test file
COCOTB_TEST_MODULES   ?= test_cnt32_clkpn_rstas


include $(shell cocotb-config --makefiles)/Makefile.sim

