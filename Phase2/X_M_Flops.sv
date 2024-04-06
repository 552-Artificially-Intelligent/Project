module X_M_Flops(
	clk, rst, wen,

	// Signals
	RegWrite_in, RegWrite_out,
	MemRead_in, MemRead_out, 
	MemWrite_in, MemWrite_out, 
	MemtoReg_in, MemtoReg_out, 
	SavePC_in, SavePC_out, 
	halt_in, halt_out, 



	// Data
	instruction_in, instruction_out
	b_in, b_out, 
	ALUresult_in, ALUresult_out, 
	oldPC_in, oldPC_out, 
	newPC_in, newPC_out, 
	reg_dest_in, reg_dest_out,
	Source2_in, Source2_out
);

input clk, rst, wen;

input RegWrite_in, MemRead_in, MemWrite_in, MemtoReg_in, SavePC_in, halt_in;
input [15:0] instruction_in, b_in, ALUresult_in, oldPC_in, newPC_in;
input [3:0] reg_dest_in, Source2_in;

output RegWrite_out, MemRead_out, MemWrite_out, MemtoReg_out, SavePC_out, halt_out;
output [15:0] instruction_out, b_out, ALUresult_out, oldPC_out, newPC_out;
output [3:0] reg_dest_out, Source2_out;


// Signals
dff RegWrite_dff(.clk(clk), .rst(rst), .wen(wen), .d(RegWrite_in), .q(RegWrite_out));
dff MemRead_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemRead_in), .q(MemRead_out));
dff MemWrite_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemWrite_in), .q(MemWrite_out));
dff MemtoReg_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemtoReg_in), .q(MemtoReg_out));
dff SavePC_dff(.clk(clk), .rst(rst), .wen(wen), .d(SavePC_in), .q(SavePC_out));
dff halt_dff(.clk(clk), .rst(rst), .wen(wen), .d(halt_in), .q(halt_out));

// 4 Bit Data
dff reg_dest_dff[3:0] (.clk(clk), .rst(rst), .wen(wen), .d(reg_dest_in), .q(reg_dest_out));
dff Source2_dff[3:0] (.clk(clk), .rst(rst), .wen(wen), .d(Source2_in), .q(Source2_out));

// 16 Bit Data
Register instruction_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(instruction_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(instruction_out), .Bitline2());
Register b_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(b_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(b_out), .Bitline2());
Register ALUresult_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(ALUresult_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(ALUresult_out), .Bitline2());
Register oldPC_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(oldPC_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(oldPC_out), .Bitline2());
Register newPC_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(newPC_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(newPC_out), .Bitline2());


endmodule