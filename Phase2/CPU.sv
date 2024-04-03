module cpu(clk, rst_n, hlt, pc);
input clk, rst_n;
output hlt;
output [15:0] pc;

////////////////////////////////////////////////////

// Instantiate the Instruction memory.v module
   // output  [15:0] data_out;
   // input [15:0]   data_in;
   // input [ADDR_WIDTH-1 :0]   addr;
   // input          enable;
   // input          wr;
   // input          clk;
   // input          rst;
// List of nets
// Instruction wires
wire [15:0] instruction;
  
// Branch wires
wire [15:0] nextPC, programCount, pcInc, branchAdd, pcBranch;
wire [2:0] cond, NVZflag;
wire do_branch;

// Control wires
wire [2:0] ALUop;
wire ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite, branch_inst, branch_src, RegDst, PCs, LoadPartial, SavePC, Hlt;
  
// Register wires
wire [3:0] SrcReg1, SrcReg2, DstReg;
wire [15:0] DstData, SrcData1, SrcData2;
wire [15:0] data_out, data_in, addr;
  
// ALU wires
wire [15:0] A, B, result;

// Flag wires
wire [2:0] NVZ_out;

// PC and HLT Connections
assign pc = programCount;
assign hlt = Hlt;

// data_out, data_in, addr, enable, wr, clk, rst
memory1c inst_memory(.data_out(instruction), .data_in(16'hXXXX), .addr(programCount), 
					.rst(1'b1), .enable(1'b1), .wr(1'b0), .clk(clk));
  
// Branch

assign cond = instruction[11:9];
  
Branch branch0(.branch_inst(branch_inst), .cond(cond), .NVZflag(NVZ_out), .do_branch(do_branch));
  
wire unused1, unused2;

//PURPOSE: increment program counter
//OUTPUT: pcInc = programCount + 2
CLA_16bit cla_inc(.A(programCount), .B(16'h0002), .Cin(1'b0), .Sum(pcInc), .Cout(unused1));
 
//branchAdd = instruction[8:0] right-shifted and sign-extended
assign branchAdd =  {{6{instruction[8]}}, instruction[8:0], 1'b0};
  
//PURPOSE: calculate value for branches
//OUTPUT: pcBranch = branchAdd + pcInc
CLA_16bit cla_br(.A(pcInc), .B(branchAdd), .Cin(1'b0), .Sum(pcBranch), .Cout(unused2));

wire delayTime;
//Delay doesn't do anything (right now)
BitReg delay(.D(((delayTime === 1'bz) | (delayTime === 1'bx)) ? (1'b0) : ((Hlt & ~delaytime) ? 1'b1 : 1'b0)), .Q(delaytime), 
   .wen(1'b1), .clk(clk), .rst(~rst_n));


// assign nextPC = ~Hlt ? (do_branch ? (branch_src ? SrcData1 : pcBranch) : pcInc) : programCount;
//PURPOSE: determine next value of program counter (PC)
//RESULT:
// - If program is halted, currentPc
// - Elif do_branch enabled, either SrcData1 (jump) or pc_branch (branch) depending on branch_src (1 if jump)
// - Else, currentPc+2
assign nextPC = ~Hlt | (Hlt & delayTime) ? (do_branch ? (branch_src ? SrcData1 : pcBranch) : pcInc) : 
               programCount;

// Input rst_n into enable since it is active low async reset
//PURPOSE: program counter - resposible for actually setting the PC to the appropriate next value 
//INPUTS: clk (clock), en(!haltEnabled), next(next programCount), rst_n (reset)
//OUTPUTS: current programCount (.PC)
PC pc0(.clk(clk), .en(~Hlt), .next(nextPC), .PC(programCount), .rst_n(rst_n));

/*
!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!CONTROL!!!!!!!!!!!!!!!!!!
INPUT:
	- .opcode: instruction[15:12]
OUTPUT: 
	- .ALUOp: ALU operation to be performed
	- .ALUsrc: set to 1 if anything besides SrcReg2 is to be used as the 2nd ALU operation
	- .MemtoReg: controls whether value to write comes from data memory (1) or ALU (0)
	- .RegWrite: controls whether WriteReg is written to
	- .MemRead: should control whether Memory is read; does nothing in practice (BUG???)
	- .MemWrite: controls whether Memory is written to
	- .branch_inst: ???
	- .branch_src: whether to use jump value or branch value for PC
	- .RegDst: should be used to determine which value to write to register, currently unused (BUG???)
	- .PCs: whether PCS instruction is executed (saves PC value)
	- .LoadPartial: set to 1 if doing LLB or LHB, set to 0 otherwise
	- .SavePC: set to 1 if PCS instruction is being executed, set to 0 otherwise
	- .Hlt: whether to halt program (only if OPCODE = 1111)
*/
Control control0(.opcode(instruction[15:12]), .ALUOp(ALUop), 
                   .ALUsrc(ALUsrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), 
                   .MemRead(MemRead), .MemWrite(MemWrite), .branch_inst(branch_inst), 
                   .branch_src(branch_src), .RegDst(RegDst), .PCs(PCs), .LoadPartial(LoadPartial), 
		   .SavePC(SavePC), .Hlt(Hlt));
  
/*
!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!REGISTERFILE!!!!!!!!!!!!!!!!!!
INPUT:
	- .clk: Clock
	- .rst: reset 
	- .SrcReg1: first reg to be read, currently set to bits 7-4, unless doing LLB or LHB
	- .SrcReg2: second reg to be read, currently set to bits 3-0
	- .DstReg: register to be written to (if applicable)
	- .WriteReg: controls whether DstReg is written to, from Control 
	- .DstData: data to be written into DestReg - complicated logic
		-if instruction is LLB or LHB:
			- if LHB, set upper 8 bits - {[SrcData1[15:8], instruction[7:0]}
			- else (LLB), set lower 8 bits - {[SrcData1[15:8], instruction[7:0]}
		-else:
			- if MemtoReg is enabled, set it to data_out (output of data memory?)
			- else, set it to result (ALU result)
INOUT: 
	- .SrcData1: output from when SrcReg1 is read
	- .SrcData2: output from when SrcReg2 is read
*/
assign DstReg = instruction[11:8];
assign SrcReg1 = LoadPartial ? instruction[11:8] : instruction[7:4];
assign SrcReg2 = instruction[3:0];
//What is this??? Look into this
//TODO TODO TODO: ADD FUNCTIONALITY FOR PCS
assign DstData = LoadPartial ? 
			(instruction[12] ? 
				({instruction[7:0], SrcData1[7:0]}) : 
				({SrcData1[15:8], instruction[7:0]})) :
  			SavePC ?
				pcInc :
				MemtoReg ? data_out : result;

// ALU
// The assembly level syntax for ADD, PADDSB, SUB, XOR and RED is:
// Opcode rd, rs, rt
// SLL, SRA, ROR:
// Opcode rd, rs, imm
/*
!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!ALU!!!!!!!!!!!!!!!!!!	
*/
assign A = SrcData1;
assign B = ALUsrc ? ((LoadPartial | SavePC) ? 16'h0000 : 
		{{12{instruction[3]}}, instruction[3:0]}) : SrcData2;
ALU ALU0(.A(A), .B(B), .opcode(ALUop), .result(result), .nvz_flags(NVZflag));






// Data Memory second memory.sv instationation
// LHB 1011, LLB 1010
assign data_in = SrcData1;
// instruction[15:13] == 3'b101 ? (instruction[12] ? ({instruction[7:0], data_out[7:0]}) : ({data_out[15:8], instruction[7:0]})) :
assign addr = result;
memory1d data_memory(.data_out(data_out), .data_in(data_in), .addr(addr), 
                     .enable(MemRead | MemWrite), .wr(MemWrite), .clk(clk), .rst(~rst_n));



// Flag Register
FLAG_reg flg_reg0(.clk(clk), .rst_n(rst_n), .en(~instruction[15]), 
	.flags(NVZflag), .opcode(ALUop), .N_flag(NVZ_out[2]), .Z_flag(NVZ_out[0]), .V_flag(NVZ_out[1]));

// IDEA: We have the same modules in each stage,
// but for all the interconnects the will be instantiated in
// the flops modules before it
//===============================================
// 			Instruction Fetch Stage
//===============================================

// TODO: Move here Pipeline Flops
// TODO: Move here PC regs
// TODO: Split Control into PC/Instruction Only Control
// TODO: Move here Instruction Memory

// TODO: Resolve IF Stall


//===============================================
// 			Instruction Decode Stage
//===============================================

// TODO: Move here Pipeline Flops

// General Register File
///////////////////////////////////////////////////////////////////////
// TODO: Currently only chooses SrcReg2 as the last 4 bits of the instruction
// for ALU
///////////////////////////////////////////////////////////////////////
// Treat the last 4 bits as rt for ADD, PADDSB, SUB, XOR, RED
RegisterFile rf_0(.clk(clk), .rst(~rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), 
             .DstReg(DstReg), .WriteReg(RegWrite), .DstData(DstData), 
             .SrcData1(SrcData1), .SrcData2(SrcData2));

// TODO: Split Control into everything less PC/Instruction
// TODO: Move here NVZ flag regs
// TODO: Move here Data hazard detect

// TODO: Resolve ID Flushes/Stall

//===============================================
// 			Execute Stage
//===============================================

// TODO: Move here Pipeline Flops
// TODO: ALU
// TODO: Forwarding

// TODO: Maybe separate wires/modules/assigns for normal vs forward inputs


//===============================================
// 			Memory Stage
//===============================================

// TODO: Move here Pipeline Flops
// TODO: Move here Data Memory


//===============================================
// 			Memory Writeback Stage
//===============================================

// TODO: Maybe nothing, but a single assign statement/cascaded mux saying which to writeback


  

  

endmodule