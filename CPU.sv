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
wire ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite, branch_inst, branch_src, RegDst, PCs, Hlt;
  
// Register wires
wire [3:0] SrcReg1, SrcReg2, DstReg;
wire [15:0] DstData, SrcData1, SrcData2;
wire WriteReg;
wire [15:0] data_out, data_in, addr;
  
// ALU wires
wire [15:0] A, B, result;

// Flag wires
wire [2:0] NVZ_out;

// data_out, data_in, addr, enable, wr, clk, rst
memory1c inst_memory(.data_out(instruction), .data_in(16'hXXXX), .addr(programCount), 
					.rst(1'b1), .enable(1'b1), .wr(1'b0), .clk(clk));
  
// TODO: PC and BRANCH stuff
// Have a mux that chooses between current PC or branch PC
// Branch

assign cond = instruction[11:9];
  
Branch branch0(.branch_inst(branch_inst), .cond(cond), .NVZflag(NVZ_out), .do_branch(do_branch));
  
wire unused1, unused2;
CLA_16bit cla_inc(.A(programCount), .B(16'h0002), .Cin(1'b0), .Sum(pcInc), .Cout(unused1));
  
assign branchAdd =  {{6{instruction[8]}}, instruction[8:0], 1'b0};
  
CLA_16bit cla_br(.A(pcInc), .B(branchAdd), .Cin(1'b0), .Sum(pcBranch), .Cout(unused2));

assign nextPC = ~Hlt ? (do_branch ? (branch_src ? SrcData1 : pcBranch) : pcInc) : programCount;
// Input rst_n into enable since it is active low async reset
PC pc0(.clk(clk), .en(~Hlt), .next(nextPC), .PC(programCount), .rst_n(rst_n));



// TODO Control
Control control0(.opcode(instruction[15:12]), .ALUOp(ALUop), 
                   .ALUsrc(ALUsrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), 
                   .MemRead(MemRead), .MemWrite(MemWrite), .branch_inst(branch_inst), 
                   .branch_src(branch_src), .RegDst(RegDst), .PCs(PCs), .Hlt(Hlt));
  
  



// Register File
assign WriteReg = RegWrite;
assign DstReg = instruction[11:8];
assign SrcReg1 = instruction[15:13] == 3'b101 ? instruction[11:8] : instruction[7:4];
assign SrcReg2 = instruction[3:0];
assign DstData = (instruction[15:13] == 3'b101) ? (instruction[12] ? 
				({instruction[7:0], SrcData1[7:0]}) : 
				({SrcData1[15:8], instruction[7:0]})) :
  				MemtoReg ? data_out : result;
///////////////////////////////////////////////////////////////////////
// TODO: Currently only chooses SrcReg2 as the last 4 bits of the instruction
// for ALU
///////////////////////////////////////////////////////////////////////
// Treat the last 4 bits as rt for ADD, PADDSB, SUB, XOR, RED
RegisterFile rf_0(.clk(clk), .rst(~rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), 
             .DstReg(DstReg), .WriteReg(WriteReg), .DstData(DstData), 
             .SrcData1(SrcData1), .SrcData2(SrcData2));

// ALU
// The assembly level syntax for ADD, PADDSB, SUB, XOR and RED is:
// Opcode rd, rs, rt
// SLL, SRA, ROR:
// Opcode rd, rs, imm
assign A = SrcData1;
assign B = ALUsrc ? ((instruction[15:13] == 3'b101) ? 16'h0000 : 
		{{12{instruction[3]}}, instruction[3:0]}) : SrcData2;
ALU ALU0(.A(A), .B(B), .opcode(ALUop), .result(result), .nvz_flags(NVZflag));






// Data Memory second memory.sv instationation
// LHB 1011, LLB 1010
assign data_in = SrcData1;
// instruction[15:13] == 3'b101 ? (instruction[12] ? ({instruction[7:0], data_out[7:0]}) : ({data_out[15:8], instruction[7:0]})) :
assign addr = result;
memory1d data_memory(.data_out(data_out), .data_in(data_in), .addr(addr), 
                     .enable(1'b1), .wr(MemWrite), .clk(clk), .rst(~rst_n));



// Flag Register
FLAG_reg flg_reg0(.clk(clk), .rst_n(rst_n), .en(~instruction[15]), 
	.flags(NVZflag), .opcode(ALUop), .N_flag(NVZ_out[2]), .Z_flag(NVZ_out[0]), .V_flag(NVZ_out[1]));





// assign programCount = ~rst_n ? 16'h0000 : programCount;
assign pc = programCount;
assign hlt = Hlt;
  

  

endmodule