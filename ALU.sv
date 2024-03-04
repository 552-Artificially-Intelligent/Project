// module ALU(
// 	input [15:0] A,
// 	input [15:0] B,
// 	// Ignore the MSB of opcode since all ALU instructions are 0 MSB
// 	input [2:0] opcode,
// 	output [15:0] result,
// 	// Maybe add a flag for a zero/ nrz flags
// );

module ALU(A, B, opcode, result);
input [15:0] A;
input [15:0] B;
input [2:0] opcode;
output [15:0] result;

// Lest of wires for the result of each module
wire [15:0] ADDSUB_result, XOR_result, PADDSB_result, RED_result,
			SLL_result, SRA_result, ROR_result;

// ADD/SUB
// Sub or add is dictated by the opcode[0]
SATADDSUB_16bit iSAS16_0(.A(A), .B(B), .sub(opcode[0]), .Sum(ADDSUB_result));

// XOR
assign XOR_result = A ^ B;

// PADDSB
PADDSB iPA_0(.A(A), .B(B), .Sum(PADDSB_result));

// RED
RED iRED_0(.A(A[15:8]), .B(A[7:0]), .C(B[15:8]), .D(B[7:0]), .Sum_ABCD(RED_result));

// SLL/SRA
// To indicate Mode 0=SLL or 1=SRA
// Based on the design description imm has to be 4 bit, so we use B[3:0]
Shifter ishift_0(.Shift_In(A), .Shift_Val(B[3:0]), .Mode(opcode[0]), .Shift_Out(SLL_result));
assign SRA_result = SLL_result;

// ROR 
ROR iROR_0(.Shift_In(A), .Shift_Val(B[3:0]), .Shift_Out(ROR_result));



assign result = (~opcode[2] & ~opcode[1]) ? ADDSUB_result :	// opcode = 00X
				(~opcode[2] & ~opcode[0]) ? XOR_result : // opcode = 0X0
				(~opcode[2]) ? RED_result : // opcode = 0XX
				(~opcode[1] & ~opcode[0]) ?  SLL_result : // opcode = X00
				(~opcode[1]) ? SRA_result : // opcode = X0X
				(~opcode[0]) ? ROR_result : // opcode = XX0
				PADDSB_result; // last of the opcode possibilities


endmodule