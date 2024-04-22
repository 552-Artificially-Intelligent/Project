
# List all SystemVerilog and Verilog files in the current directory
SV_FILES := $(wildcard *.sv)
V_FILES := $(wildcard *.v)
#################################################################
#						Edit TB File Here						#
#################################################################
TB_FILE := project-phase3-testbench.v
COMPILE_FILE := iDUT.vvp

# Define the default target
.DEFAULT_GOAL := all

# Rule to compile all files
all: $(COMPILE_FILE)

# Rule to compile all Verilog and SystemVerilog files into a single compiled file
# Choose either to test the main testbench or all the test benches
$(COMPILE_FILE): $(SV_FILES) $(V_FILES)
	iverilog -g2012 -o $@ $(filter-out %_tb.sv %_tb.v %_TB.sv %_TB.v $(TB_FILE), $(SV_FILES) $(V_FILES)) $(TB_FILE)
# 	iverilog -g2012 -o $@ $(SV_FILES) $(V_FILES)

# Rule to run the compiled file and generate VCD
run: $(COMPILE_FILE)
	vvp $(COMPILE_FILE) -o waves.vcd

# Rule to clean compiled files
clean:
	rm -f $(COMPILE_FILE) waves.vcd

.PHONY: all run clean