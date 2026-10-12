# Makefile

# defaults
SIM ?= icarus

# include vcs setup for the tests
include ${MAKEFILE_INC_HOME}/makefile_vcs.inc

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ${CELL_LIB_HOME}/cell_sim_pcnt.v
VERILOG_SOURCES += c2k_EQEP.v 

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = c2k_EQEP

# Extra options
COCOTB_PLUSARGS += +define+UNIT_DELAY

# COCOTB_TEST_MODULES is the basename of the Python test file
COCOTB_TEST_MODULES   ?= test_c2k_EQEP


include $(shell cocotb-config --makefiles)/Makefile.sim

