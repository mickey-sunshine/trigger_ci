# Makefile

# defaults
SIM ?= icarus

# include vcs setup for the tests
include ${MAKEFILE_INC_HOME}/makefile_vcs.inc

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ${CELL_LIB_HOME}/cell_sim_pcnt.v
VERILOG_SOURCES += C2000_PWM_rstp.v 

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = C2000_PWM_rstp

# Extra options
PLUSARGS += +define+UNIT_DELAY

# MODULE is the basename of the Python test file
MODULE   ?= test_C2000_PWM_rstp


include $(shell cocotb-config --makefiles)/Makefile.sim

