# Phase 1
ECE 552 Project Work
Phase 1 is a single cycle processor, so it runs one instruction per cycle.

To run: 
1. Edit memory.v so that the instruction memory is reading to the right test (test1, test2, test3), and the other tests are commented out
```
if (rst) begin
         //load loadfile_all.img
         if (!loaded) begin
            // $readmemh("loadfile_all.img", mem);
            $readmemh("test1Out.img", mem);
            // $readmemh("test2Out.img", mem);
            // $readmemh("test3Out.img", mem);
            loaded = 1;
         end
```
2. Either run on modelsim and use the project-phase1-testbench.v
	a. Or run the Makefile first by editing the Makefile and choosing the desired testbench file and/or other defaults. Run `make` to compile, and then run `make run` to generate the vcd file. Use another waveform viewer like gtkwave or scansion (gtkwave is blurry on mac) to view the .vcd file.

Received Grade: 30/100
