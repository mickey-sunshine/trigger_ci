# Makefile

# defaults
SIM ?= icarus

# Set the top-level language
TOPLEVEL_LANG ?= verilog

# Get current working directory
CWD := $(shell pwd)

# Testbench directory
TEST_DIR := $(CWD)

# RTL directory
RTL_DIR := $(CWD)

# include vcs setup for the tests
ifeq ($(SIM), vcs)
  include ${MAKEFILE_INC_HOME}/makefile_vcs.inc
else  
  $(warning Simulator is not vcs, skipping vcs makefile include) 
endif 

# Testbench files location
SOURCES = $(wildcard $(TEST_DIR)/test_*.py)

export PYTHONPATH := $(CWD)/$(TEST_DIR):$(PYTHONPATH)

# Source files
VERILOG_SOURCES += ${CELL_LIB_HOME}/cell_sim_pcnt.v
VERILOG_SOURCES += ae_case2.v
VERILOG_SOURCES += edge_detection.v
VERILOG_SOURCES += off_pwm_ctrl.v
VERILOG_SOURCES += off_pwm_mode_ctrl.v
VERILOG_SOURCES += off_pwm_sel.v
VERILOG_SOURCES += pwm_protection_g1p6_16b.v
VERILOG_SOURCES += signal_dly_ctrl.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ae_case2

# Extra options
COCOTB_PLUSARGS += +define+UNIT_DELAY

# MODULE is the basename of the Python test file
COCOTB_TEST_MODULES	?= test_ae_case2

# Set HDL time unit and precision
COCOTB_HDL_TIMEUNIT ?= 1ns
COCOTB_HDL_TIMEPRECISION ?= 1ps

# Enable waveform dumping
WAVES ?= 1

include $(shell cocotb-config --makefiles)/Makefile.sim
