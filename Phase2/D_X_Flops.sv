module D_X_Flops(
	clk, rst, wen,
	// Signals
	ALUsrc_in, ALUsrc_out,
	MemtoReg_in, MemtoReg_out,
	RegWrite_in, RegWrite_out,
	MemRead_in, MemRead_out,
	MemWrite_in, MemWrite_out,
	branch_inst_in, branch_inst_out,
	branch_src_in, branch_src_out,
	RegDst_in, RegDst_out,
	SavePC_in, SavePC_out,
	halt_in, halt_out,
	LoadPartial_in, LoadPartial_out,

	// Data
	instruction_in, instruction_out,
	a_in, a_out,
	b_in, b_out,
	imm_in, imm_out,
	oldPC_in, oldPC_out,
	newPC_in, newPC_out,
	reg_dest_in, reg_dest_out,
	Source1_in, Source1_out,
	Source2_in, Source2_out
);

input clk, rst, wen;

input ALUsrc_in,
	MemtoReg_in,
	RegWrite_in,
	MemRead_in,
	MemWrite_in,
	branch_inst_in,
	branch_src_in,
	RegDst_in,
	SavePC_in,
	halt_in,
	LoadPartial_in;
input [15:0] instruction_in, a_in, b_in, imm_in, oldPC_in, newPC_in;
input [3:0] reg_dest_in, Source1_in, Source2_in;


output ALUsrc_out,
	MemtoReg_out,
	RegWrite_out,
	MemRead_out,
	MemWrite_out,
	branch_inst_out,
	branch_src_out,
	RegDst_out,
	SavePC_out,
	halt_out,
	LoadPartial_out;
output [15:0] instruction_out, a_out, b_out, imm_out, oldPC_out, newPC_out;
output [3:0] reg_dest_out, Source1_out, Source2_out;

////////////////////////////////////////////////////////

// Signals
dff ALUsrc_dff(.clk(clk), .rst(rst), .wen(wen), .d(ALUsrc_in), .q(ALUsrc_out));
dff MemtoReg_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemtoReg_in), .q(MemtoReg_out));
dff RegWrite_dff(.clk(clk), .rst(rst), .wen(wen), .d(RegWrite_in), .q(RegWrite_out));
dff MemRead_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemRead_in), .q(MemRead_out));
dff MemWrite_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemWrite_in), .q(MemWrite_out));
dff branch_inst_dff(.clk(clk), .rst(rst), .wen(wen), .d(branch_inst_in), .q(branch_inst_out));
dff branch_src_dff(.clk(clk), .rst(rst), .wen(wen), .d(branch_src_in), .q(branch_src_out));
dff RegDst_dff(.clk(clk), .rst(rst), .wen(wen), .d(RegDst_in), .q(RegDst_out));
dff SavePC_dff(.clk(clk), .rst(rst), .wen(wen), .d(SavePC_in), .q(SavePC_out));
dff halt_dff(.clk(clk), .rst(rst), .wen(wen), .d(halt_in), .q(halt_out));
dff LoadPartial_dff(.clk(clk), .rst(rst), .wen(wen), .d(LoadPartial_in), .q(LoadPartial_out));

// 4 Bit Data
dff reg_dest_dff[3:0] (.clk(clk), .rst(rst), .wen(wen), .d(reg_dest_in), .q(reg_dest_out));
dff Source1_dff[3:0] (.clk(clk), .rst(rst), .wen(wen), .d(Source1_in), .q(Source1_out));
dff Source2_dff[3:0] (.clk(clk), .rst(rst), .wen(wen), .d(Source2_in), .q(Source2_out));

// 16 Bit Data
Register2 instruction_reg (.clk(clk), .rst(rst), .WriteReg(wen), .D(instruction_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(instruction_out), .Bitline2());
Register2 a_reg (.clk(clk), .rst(rst), .WriteReg(wen), .D(a_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(a_out), .Bitline2());
Register2 b_reg (.clk(clk), .rst(rst), .WriteReg(wen), .D(b_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(b_out), .Bitline2());
Register2 imm_reg (.clk(clk), .rst(rst), .WriteReg(wen), .D(imm_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(imm_out), .Bitline2());
Register2 oldPC_reg (.clk(clk), .rst(rst), .WriteReg(wen), .D(oldPC_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(oldPC_out), .Bitline2());
Register2 newPC_reg (.clk(clk), .rst(rst), .WriteReg(wen), .D(newPC_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(newPC_out), .Bitline2());




endmodule