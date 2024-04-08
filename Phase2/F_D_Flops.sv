module F_D_Flops(
	clk, rst, wen, instruction_in, oldPC_in, newPC_in, 
	instruction_out, oldPC_out, newPC_out,
	halt_in, halt_out
);

// Currently have 2 different PCs an old and a new
// so it could maybe help with stalls and flushes.
// I think we maybe just need old PC and newPC for up to decode
// assuming decode is when branching is resolved. So basically I think
// the FLAG registers should be in the Decode stage, and it will be affected by
// the Execute stage.

input clk, rst, wen, halt_in;
input[15:0] instruction_in;
input [15:0] oldPC_in, newPC_in;
output[15:0] instruction_out;
output [15:0] oldPC_out, newPC_out;
output halt_out;
logic currentHalt, stopWrite;

// Halt detection
dff dff_halt(.clk(clk), .rst(rst), .wen(wen), .d(halt_in), .q(halt_out));

// Use registers for these values since requires 16 bits
Register reg_inst(.clk(clk), .rst(rst), .WriteReg(wen), .D(instruction_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(instruction_out), .Bitline2());

Register reg_oldPC(.clk(clk), .rst(rst), .WriteReg(wen), .D(oldPC_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(oldPC_out), .Bitline2());

Register reg_newPC(.clk(clk), .rst(rst), .WriteReg(wen), .D(newPC_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(newPC_out), .Bitline2());



endmodule