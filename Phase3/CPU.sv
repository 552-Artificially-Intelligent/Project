module cpu(clk, rst_n, hlt, pc);
input clk, rst_n;
output hlt;
output [15:0] pc;

////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
//
//===============================================
// 			Pipeline Data
//===============================================
// PC Data
wire [15:0] F_D_oldPC, D_X_oldPC, X_M_oldPC, M_W_oldPC,
			F_D_newPC, D_X_newPC, X_M_newPC, M_W_newPC,
			nextPC, programCount, pcInc, pcBranch, F_D_pcBranch;
// Instruction, no need for opcode, we can just use instruction
wire [15:0]	instruction, F_instruction, F_D_instruction, D_X_instruction, 
			X_M_instruction, M_W_instruction;
// Immediate value
wire [15:0] D_imm, D_X_imm;
// Branch Address
wire [15:0] branchAdd;
// Register Addresses Inputs 
wire [3:0] reg_dest, reg_source1, reg_source2, D_X_reg_source1, D_X_reg_source2, X_M_reg_source2, 
	D_X_reg_dest, X_M_reg_dest, M_W_reg_dest;
// Register Outputs
	// reg1 not needed in X_M since only memory goes in
wire [15:0] D_reg1, D_reg2, D_X_reg1, D_X_reg2, X_M_reg2, reg1Forward, reg2Forward;
// NVZ Flag
wire [2:0] NVZflag, cond, flagEN, NVZ_out;
// Register Address Forwarding // I wrote something here but Im not sure what, might delete
// ALU In
wire [15:0] aluA, aluB;
wire [15:0] ALUresult_in, ALUresult_out, X_M_aluB;
// ALU Out
wire [15:0] X_ALUOut, X_M_ALUOut, M_W_ALUOut;
// Memory in/out data
wire [15:0] memory_in, memory_out;
// Memory/Register Writeback data
wire [15:0] memData_In, M_mem, M_W_mem, addr;
wire [15:0] writeback_data;


//===============================================
// 			Pipeline Signal
//===============================================
// PC Data
// Stalls, Flushes, branchTaken signals
wire flush, F_stall, D_stall, stall, do_branch, 
	cache_F_stall, cache_M_stall, eitherCacheStall;
// ALUsrc*
wire D_ALUsrc, D_X_ALUsrc;
// MemtoReg*
wire D_MemtoReg, D_X_MemtoReg, X_M_MemtoReg, M_W_MemtoReg;
// RegWrite*
wire D_RegWrite, D_X_RegWrite, X_M_RegWrite, M_W_RegWrite;
// MemRead*
wire D_MemRead, D_X_MemRead, X_M_MemRead;
// MemWrite*
wire D_MemWrite, D_X_MemWrite, X_M_MemWrite;
// branch_inst*, basically branch enable
wire D_branch_inst, D_X_branch_inst;
// branch_src*, 1 = BR or reg, and 0 = B or memory
wire D_branch_src, D_X_branch_src;
// RegDst*
wire D_RegDst, D_X_RegDst;
// LoadPartial*: set to 1 if doing LLB or LHB, set to 0 otherwise
wire D_LoadPartial, D_X_LoadPartial;
// SavePC* (same assign as PCs but PCs isn't used so just use SavePC only)
wire D_SavePC, D_X_SavePC, X_M_SavePC, M_W_SavePC;
// Forwarding*
wire X_X_A_en, M_X_A_en, X_X_B_en, M_X_B_en, M_M_B_en;
// Hlt,
wire halt, F_D_halt, D_X_halt, X_M_halt, M_W_halt;
// Flag
wire flagNV, flagZ;
// Cache Miss Signals
wire cacheInstrMiss, cacheDataMiss;

//===============================================
// CPU Outputs:
// assign pc = programCount;
assign pc = M_W_oldPC;
// assign hlt = M_W_halt;
// assign hlt = M_W_halt;
assign hlt = M_W_instruction[15:0] == 16'hF000;
wire instr_miss, data_miss, instr_hit, data_hit, instr_req, data_req;
assign instr_req = 1'b1;
assign data_req = X_M_MemRead | X_M_MemWrite;
assign instr_hit = ~instr_miss;
assign data_hit = ~data_miss;
//===============================================



// IDEA: We have the same modules in each stage,
// but for all the interconnects the will be instantiated in
// the flops modules before it
//===============================================
// 			INSTRUCTION FETCH STAGE
//===============================================

// Pipeline Flops
F_D_Flops fdFlop(.clk(clk), .rst(~rst_n | flush), 
	.wen(~eitherCacheStall), .instruction_in(instruction), 
	.oldPC_in(programCount), .newPC_in(pcInc), 
	.instruction_out(F_D_instruction), .pcBranch_in(pcBranch), 
	.pcBranch_out(F_D_pcBranch),
	.oldPC_out(F_D_oldPC), .newPC_out(F_D_newPC), 
	.halt_in(halt), .halt_out(F_D_halt));

// PC regs
PC pc0(.clk(clk), .en(~halt & ~eitherCacheStall), .next(nextPC), .PC(programCount), .rst_n(rst_n));
// assign nextPC = ~(halt | stall) ? (do_branch ? (D_branch_src ? D_reg1 : F_D_pcBranch) : pcInc) : 
//                programCount;
assign nextPC = ~(halt) ? (do_branch ? (D_branch_src ? D_reg1 : F_D_pcBranch) : pcInc) : 
               programCount;


// memory1c inst_memory(.data_out(instruction), .data_in(16'hXXXX), .addr(programCount), 
// 					.rst(1'b1), .enable(1'b1), .wr(1'b0), .clk(clk));
// memory1d data_memory(.data_out(M_mem), .data_in(memData_In), .addr(addr), 
//                      .enable(X_M_MemRead | X_M_MemWrite), .wr(X_M_MemWrite), 
// 						.clk(clk), .rst(~rst_n));
// Instruction and Data Memory
assign eitherCacheStall = cache_F_stall | cache_M_stall;
CacheModule cacheInstructionData(.clk(clk), .rst(~rst_n), 
	// Either always high (because we are always reading), or maybe ~halt
	// We cannot do ~halt, because it needs to read the instruction to be able to get the signal halt
	// .readInstruction(~halt), 
	.readInstruction(1'b1), 
	.writeInstruction(1'b0), 
	.readData(X_M_MemRead), 
	.writeData(X_M_MemWrite), 
	.instr_addr(programCount), 
	.data_addr(addr), 
	.cacheInputData(memData_In), 
	// In regards to stall, I think everything before the M stage will need to stall if either
	// F or M is stalling, and M and after stages just need to stall if only M stalls
	// Im not sure actually
	// TODO
	.F_stall(cache_F_stall), 
	.M_stall(cache_M_stall), 
	// Removed the miss outputs because its enough to tell the CPU to stall
	// UPDATE: nvm we need to the miss to signal on the testbench
	.instr_miss(instr_miss), .data_miss(data_miss),
	.instr_cache_data(instruction), 
	.memory_cache_data(M_mem)
);

//Enable if there is a halt
assign halt = (~do_branch & instruction[15:12] == 4'hF);

// Increment the PC - pcInc = programCount + 2
CLA_16bit cla_inc(.A(programCount), .B(16'h0002), .Cin(1'b0), .Sum(pcInc), .Cout()); 
//branchAdd = instruction[8:0] right-shifted and sign-extended
assign branchAdd =  {{6{instruction[8]}}, instruction[8:0], 1'b0};
CLA_16bit cla_br(.A(pcInc), .B(branchAdd), .Cin(1'b0), .Sum(pcBranch), .Cout());

// Branch
Branch branch0(.branch_inst(D_branch_inst), .cond(cond), .NVZflag(NVZ_out), .do_branch(do_branch));


//===============================================
// 			INSTRUCTION DECODE STAGE
//===============================================

// Pipeline Flops
D_X_Flops D_X_flops0(
	.clk(clk), .rst(~rst_n), .wen(~D_stall | ~eitherCacheStall),
	// Signals
	.ALUsrc_in(D_ALUsrc), .ALUsrc_out(D_X_ALUsrc),
	.MemtoReg_in(D_MemtoReg), .MemtoReg_out(D_X_MemtoReg),
	.RegWrite_in(D_RegWrite), .RegWrite_out(D_X_RegWrite),
	.MemRead_in(D_MemRead), .MemRead_out(D_X_MemRead),
	.MemWrite_in(D_MemWrite), .MemWrite_out(D_X_MemWrite),
	.branch_inst_in(D_branch_inst), .branch_inst_out(D_X_branch_inst),
	.branch_src_in(D_branch_src), .branch_src_out(D_X_branch_src),
	.RegDst_in(D_RegDst), .RegDst_out(D_X_RegDst),
	.SavePC_in(D_SavePC), .SavePC_out(D_X_SavePC),
	.halt_in(F_D_halt), .halt_out(D_X_halt),
	.LoadPartial_in(D_LoadPartial), .LoadPartial_out(D_X_LoadPartial),

	// Data
	.instruction_in(F_D_instruction), .instruction_out(D_X_instruction),
	.a_in(D_reg1), .a_out(D_X_reg1), 
	.b_in(D_reg2), .b_out(D_X_reg2), 
	.imm_in(D_imm), .imm_out(D_X_imm), 
	.oldPC_in(F_D_oldPC), .oldPC_out(D_X_oldPC),
	.newPC_in(F_D_newPC), .newPC_out(D_X_newPC),
	.reg_dest_in(reg_dest), .reg_dest_out(D_X_reg_dest),
	.Source1_in(reg_source1), .Source1_out(D_X_reg_source1),
	.Source2_in(reg_source2), .Source2_out(D_X_reg_source2)
);

// Decoding the instruction down
assign reg_source1 = D_LoadPartial ? F_D_instruction[11:8] : F_D_instruction[7:4];
assign reg_source2 = (D_MemRead | D_MemWrite) ? F_D_instruction[11:8] : F_D_instruction[3:0];
// LLB	1010
// LHB	1011
// addr = (Reg[ssss] & 0xFFFE) + (sign-extend(oooo) << 1).
assign D_imm = (D_MemRead | D_MemWrite) ? {{12{F_D_instruction[3]}}, F_D_instruction[3:0], {1'b0}} :
				(F_D_instruction[15:12] == 4'b1010) ? {{8{1'b0}}, F_D_instruction[7:0]} :
				(F_D_instruction[15:12] == 4'b1011) ? {F_D_instruction[7:0], {8{1'b0}}} : 
				{{12{1'b0}}, F_D_instruction[3:0]};
// assign reg_dest = D_RegDst ? F_D_instruction[11:8] : reg_source2;
assign reg_dest = F_D_instruction[11:8];


// General Register File
wire [15:0] temp1, temp2;
assign D_reg1 = (M_W_reg_dest == reg_source1 & M_W_RegWrite) ? writeback_data : temp1;
assign D_reg2 = (M_W_reg_dest == reg_source2 & M_W_RegWrite) ? writeback_data : temp2;
RegisterFile rf_0(.clk(clk), .rst(~rst_n), .SrcReg1(reg_source1), .SrcReg2(reg_source2), 
             .DstReg(M_W_reg_dest), .WriteReg(M_W_RegWrite), .DstData(writeback_data), 
             .SrcData1(temp1), .SrcData2(temp2));
// RegisterFile rf_0(.clk(clk), .rst(~rst_n), .SrcReg1(reg_source1), .SrcReg2(reg_source2), 
//              .DstReg(M_W_reg_dest), .WriteReg(M_W_RegWrite), .DstData(writeback_data), 
//              .SrcData1(D_reg1), .SrcData2(D_reg2));

// NVZ flag regs
FLAG_reg flg_reg0(.clk(clk), .rst_n(rst_n), .en(~F_D_instruction[15]), 
	.flags(NVZflag), .opcode(F_D_instruction[14:12]), .N_flag(NVZ_out[2]), .Z_flag(NVZ_out[0]), .V_flag(NVZ_out[1]));
assign cond = F_D_instruction[11:9];

// Data hazard detect
Data_Hazard_Detect hazard_detect0(
	.opcode(X_M_instruction[15:12]), .D_X_destination_reg(X_M_reg_dest), 
	.D_source_reg(reg_source1), .stall(stall)
);

// Resolve ID Flushes/Stall
assign flush = do_branch;
assign F_stall = stall;
assign D_stall = stall;

// Control
Control control0(.opcode(F_D_instruction[15:12]), .ALUOp(), 
                   .ALUsrc(D_ALUsrc), .MemtoReg(D_MemtoReg), .RegWrite(D_RegWrite), 
                   .MemRead(D_MemRead), .MemWrite(D_MemWrite), .branch_inst(D_branch_inst), 
                   .branch_src(D_branch_src), .RegDst(D_RegDst), .PCs(), .LoadPartial(D_LoadPartial), 
		   .SavePC(D_SavePC), .Hlt(), .flagNV(flagNV), .flagZ(flagZ));


//===============================================
// 			EXECUTE STAGE
//===============================================
// Pipeline Flops
X_M_Flops X_M_flops0(
	.clk(clk), .rst(~rst_n), .wen(~eitherCacheStall),
	// Signals
	.RegWrite_in(D_X_RegWrite), .RegWrite_out(X_M_RegWrite),
	.MemRead_in(D_X_MemRead), .MemRead_out(X_M_MemRead), 
	.MemWrite_in(D_X_MemWrite), .MemWrite_out(X_M_MemWrite), 
	.MemtoReg_in(D_X_MemtoReg), .MemtoReg_out(X_M_MemtoReg), 
	.SavePC_in(D_X_SavePC), .SavePC_out(X_M_SavePC), 
	.halt_in(D_X_halt), .halt_out(X_M_halt), 

	// Data
	.instruction_in(D_X_instruction), .instruction_out(X_M_instruction), 
	.b_in(aluB), .b_out(X_M_aluB), 
	.ALUresult_in(X_ALUOut), .ALUresult_out(X_M_ALUOut), 
	.oldPC_in(D_X_oldPC), .oldPC_out(X_M_oldPC), 
	.newPC_in(D_X_newPC), .newPC_out(X_M_newPC), 
	.reg_dest_in(D_X_reg_dest), .reg_dest_out(X_M_reg_dest),
	.Source2_in(D_X_reg_source2), .Source2_out(X_M_reg_source2)
);

// ALU
assign aluA = (D_X_MemWrite | D_X_MemRead) ? reg1Forward & 16'hFFFE : 
				(D_X_LoadPartial & D_X_instruction[12]) ? (reg1Forward & 16'h00ff) :
				(D_X_LoadPartial & ~D_X_instruction[12]) ? (reg1Forward & 16'hff00) : 
				reg1Forward;
assign aluB = (D_X_ALUsrc) ? D_X_imm : reg2Forward;
wire [2:0] ALUopcode;
assign ALUopcode = (D_X_instruction[15:13] == 3'b101 | D_X_instruction[15:13] == 3'b100) ? 
					3'b000 : D_X_instruction[14:12];
ALU ALU0(.A(aluA), .B(aluB), .opcode(ALUopcode), .result(X_ALUOut), 
	.nvz_flags(NVZflag), .flagNV(flagNV), .flagZ(flagZ));

// Forwarding
Forwarding_Unit frwd_unit(
	.X_M_RegWrite(X_M_RegWrite), .X_M_MemWrite(X_M_MemWrite), .M_W_RegWrite(M_W_RegWrite), 
	.X_M_reg_dest(X_M_reg_dest), .M_W_reg_dest(M_W_reg_dest), .D_X_reg_source1(D_X_reg_source1), 
	.D_X_reg_source2(D_X_reg_source2), .X_M_reg_source2(X_M_reg_source2), 
	.EXtoEX_frwdA(X_X_A_en), .EXtoEX_frwdB(X_X_B_en), .MEMtoMEM_frwdB(M_M_B_en), 
	.MEMtoEX_frwdA(M_X_A_en), .MEMtoEX_frwdB(M_X_B_en)
);

assign reg1Forward = (X_X_A_en) ? X_M_ALUOut : 
					M_X_A_en ? writeback_data : 
					D_X_reg1;
assign reg2Forward = X_X_B_en ? X_M_ALUOut : 
					M_X_B_en ? writeback_data :
					D_X_reg2;

//===============================================
// 			MEMORY STAGE
//===============================================

// Pipeline Flops
M_W_Flops M_W_flops0(
	.clk(clk), .rst(~rst_n), .wen(~eitherCacheStall),

	// Signals
	.halt_in(X_M_halt), .halt_out(M_W_halt), 
	.MemtoReg_in(X_M_MemtoReg), .MemtoReg_out(M_W_MemtoReg), 
	.RegWrite_in(X_M_RegWrite), .RegWrite_out(M_W_RegWrite), 
	.SavePC_in(X_M_SavePC), .SavePC_out(M_W_SavePC), 

	// Data
	.instruction_in(X_M_instruction), .instruction_out(M_W_instruction), 
	.ALUresult_in(X_M_ALUOut), .ALUresult_out(M_W_ALUOut), 
	.mem_in(M_mem), .mem_out(M_W_mem), 
	.oldPC_in(X_M_oldPC), .oldPC_out(M_W_oldPC),
	.newPC_in(X_M_newPC), .newPC_out(M_W_newPC), 
	.reg_dest_in(X_M_reg_dest), .reg_dest_out(M_W_reg_dest)
);
// Data Memory
assign addr = X_M_ALUOut;
assign memData_In = M_M_B_en ? writeback_data : X_M_aluB;  
// memory1d data_memory(.data_out(M_mem), .data_in(memData_In), .addr(addr), 
//                      .enable(X_M_MemRead | X_M_MemWrite), .wr(X_M_MemWrite), .clk(clk), .rst(~rst_n));

// wire oneDelayMWHalt, twoDelayMWHalt, threeDelayMWHalt;
// dff dffHalt1(.clk(clk), .rst(~rst_n), .wen(1'b1), .d(M_W_halt), .q(oneDelayMWHalt));
// dff dffHalt2(.clk(clk), .rst(~rst_n), .wen(1'b1), .d(oneDelayMWHalt), .q(twoDelayMWHalt));
// dff dffHalt3(.clk(clk), .rst(~rst_n), .wen(1'b1), .d(twoDelayMWHalt), .q(threeDelayMWHalt));
//===============================================
// 			MEMORY WRITEBACK STAGE
//===============================================
// MemtoReg_ii/MemtoReg_out from flop
assign writeback_data = (M_W_MemtoReg) ? M_W_mem : (M_W_SavePC) ? M_W_newPC : M_W_ALUOut;
// assign writeback_data = (M_W_MemtoReg) ? M_W_mem : (M_W_SavePC) ? M_W_newPC : X_M_ALUOut;
  

  

endmodule