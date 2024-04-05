module F_D_Flops(
	clk, rst, en, instruction_in, oldPC_in, new_PC_in, 
	instr_out, oldPC_out, new_PC_out
);

// Currently have 2 different PCs an old and a new
// so it could maybe help with stalls and flushes.
// New/Old PCs might be needed for the entirety of the pipelines
// or at least that's how they would be implemented for now.

input clk, rst, en;
input [15:0] instruction_in, oldpc_in, newpc_in;
output [15:0] instruction_out, oldpc_out, newpc_out;

// Use registers for these values since requires 16 bits
Register reg_inst(.clk(clk), .rst(rst), .WriteReg(en), .D(instruction_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(instruction_out), .Bitline2());

Register reg_oldPC(.clk(clk), .rst(rst), .WriteReg(en), .D(oldpc_in), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(newpc_in), .Bitline2());

Register reg_newPC(.clk(clk), .rst(rst), .WriteReg(en), .D(oldpc_out), 
	.ReadEnable1(1'b1), .ReadEnable2(1'b0), 
	.Bitline1(newpc_out), .Bitline2());


endmodule