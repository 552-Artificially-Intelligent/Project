module M_W_Flops(
	clk, rst, wen,

	// Signals
	halt_in, halt_out, 
	MemtoReg_in, MemtoReg_out, 
	RegWrite_in, RegWrite_out, 
	SavePC_in, SavePC_out, 


	// Data
	instruction_in, instruction_out, 
	ALUresult_in, ALUresult_out, 
	mem_in, mem_out, 
	oldPC_in, oldPC_out,
	newPC_in, newPC_out, 
	reg_dest_in, reg_dest_out, 
);

input clk, rst, wen;

input halt_in, MemtoReg_in, RegWrite_in, SavePC_in;
input [15:0] instruction_in, mem_in, ALUresult_in, oldPC_in, newPC_in;
input [3:0] reg_dest_in;

output halt_out, MemtoReg_out, RegWrite_out, SavePC_out;
output [15:0] instruction_out, mem_out, ALUresult_out, oldPC_out, newPC_out;
output [3:0] reg_dest_out;


// Signals
dff halt_dff(.clk(clk), .rst(rst), .wen(wen), .d(halt_in), .q(halt_out));
dff MemtoReg_dff(.clk(clk), .rst(rst), .wen(wen), .d(MemtoReg_in), .q(MemtoReg_out));
dff RegWrite_dff(.clk(clk), .rst(rst), .wen(wen), .d(RegWrite_in), .q(RegWrite_out));
dff SavePC_dff(.clk(clk), .rst(rst), .wen(wen), .d(SavePC_in), .q(SavePC_out));

// 4 Bit Data
dff reg_dest_dff[3:0] (.clk(clk), .rst(rst), .wen(wen), .d(reg_dest_in), .q(reg_dest_out));

// 16 Bit Data
Register instruction_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(instruction_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(instruction_out), .Bitline2());
Register mem_reg(.clk(clk), .rst(rst), .WriteReg(wen), .D(mem_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(mem_out), .Bitline2());
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