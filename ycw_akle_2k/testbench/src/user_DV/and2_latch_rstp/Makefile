# Makefile

# defaults
SIM ?= icarus

# include vcs setup for the tests
include ${MAKEFILE_INC_HOME}/makefile_vcs.inc

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += and2_latch_rstp.v 

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = and2_latch_rstp

# Extra options
COCOTB_PLUSARGS += +define+UNIT_DELAY

# COCOTB_TEST_MODULES is the basename of the Python test file
COCOTB_TEST_MODULES   ?= test_and2_latch_rstp


include $(shell cocotb-config --makefiles)/Makefile.sim

