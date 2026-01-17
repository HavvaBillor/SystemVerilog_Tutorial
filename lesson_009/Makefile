########################################################
# GENERIC VERILOG / MODELSIM MAKEFILE
# AUTO-DETECT:
#  - RTL only
#  - TB only
#  - RTL + TB
########################################################

# ---- Tools ----
VLIB = vlib
VLOG = vlog
VSIM = vsim

# ---- Directories ----
RTL_DIR  = rtl
TB_DIR   = tb
WORK_DIR = work

# ---- Files ----
# All RTL files (may be empty)
RTL_FILES := $(wildcard $(RTL_DIR)/*.sv)

# Default testbench (first .v under tb/)
TB ?= $(notdir $(firstword $(wildcard $(TB_DIR)/*.sv)))
TB_FILE := $(TB_DIR)/$(TB)

# Top module name (from TB filename)
TB_TOP := $(basename $(TB))

########################################################
# Targets
########################################################
.PHONY: all compile sim sim_batch clean help

all: compile

help:
	@echo "USAGE:"
	@echo "  make compile"
	@echo "  make sim"
	@echo "  make sim TB=<testbench.v>"
	@echo "  make sim_batch TB=<testbench.v>"
	@echo ""
	@echo "AUTO BEHAVIOR:"
	@echo "  - RTL varsa derler"
	@echo "  - RTL yoksa sadece TB derler"
	@echo "  - vlog asla bos calismaz"

########################################################
# COMPILE (AUTO)
########################################################
compile:
	@echo "[] 1. Create work library"
	@mkdir -p $(WORK_DIR)
	$(VLIB) $(WORK_DIR)

	@if [ -n "$(RTL_FILES)" ]; then \
		echo "[] 2. Compile RTL files"; \
		$(VLOG) -work $(WORK_DIR) $(RTL_FILES); \
	else \
		echo "[i] No RTL files found, skipping RTL compile"; \
	fi

	@if [ -f "$(TB_FILE)" ]; then \
		echo "[] 3. Compile Testbench ($(TB))"; \
		$(VLOG) -work $(WORK_DIR) $(TB_FILE); \
	else \
		echo "[i] No Testbench found, skipping TB compile"; \
	fi

	@echo "[✓] Compile completed"

########################################################
# GUI SIMULATION (AUTO)
########################################################
sim: compile
	@if [ -z "$(TB)" ]; then \
		echo "[X] No testbench available for simulation"; \
		exit 1; \
	fi
	@echo "[] Launching ModelSim (GUI)"
	$(VSIM) -work $(WORK_DIR) $(TB_TOP)
########################################################
# BATCH SIMULATION (AUTO VCD IF dump.vcd EXISTS)
########################################################
sim_batch: compile
	@if [ -z "$(TB)" ]; then \
		echo "[X] No testbench available for simulation"; \
		exit 1; \
	fi
	@if [ -f dump.vcd ]; then \
		echo "[] Running ModelSim (Batch + VCD auto-detected)"; \
		$(VSIM) -c -work $(WORK_DIR) $(TB_TOP) -do "\
		vcd file dump.vcd; \
		vcd add -r /*; \
		run -all; \
		vcd flush; \
		quit"; \
	else \
		echo "[] Running ModelSim (Batch)"; \
		$(VSIM) -c -work $(WORK_DIR) $(TB_TOP) -do "run -all; quit"; \
	fi
	@echo "[✓] Batch simulation completed"
	
########################################################
# CLEAN
########################################################
clean:
	rm -rf $(WORK_DIR) transcript vsim.wlf
	@echo "[✓] Clean completed"

########################################################
# KULLANIM ORNEKLERI
########################################################
#
# 1) SADECE TESTBENCH VAR (rtl/ bos olabilir)
#    tb/tb_example.v
#
#    make compile
#    make sim
#
# ------------------------------------------------------
#
# 2) RTL + TESTBENCH
#    rtl/full_adder.v
#    tb/tb_full_adder.v
#
#    make compile
#    make sim TB=tb_full_adder.v
#
# ------------------------------------------------------
#
# 3) BATCH SIMULATION
#
#    make sim_batch TB=tb_full_adder.v
#
# ------------------------------------------------------
#
# 4) TEMIZLIK
#
#    make clean
#
########################################################