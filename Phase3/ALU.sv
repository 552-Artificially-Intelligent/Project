// The assembly level syntax for ADD, PADDSB, SUB, XOR and RED is:
// Opcode rd, rs, rt
// SLL, SRA, ROR:
// Opcode rd, rs, imm
/*
!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!ALU!!!!!!!!!!!!!!!!!!	
*/
// assign A = SrcData1;
// assign B = ALUsrc ? ((LoadPartial | SavePC) ? 16'h0000 : 
// 		{{12{instruction[3]}}, instruction[3:0]}) : SrcData2;
// Take into account the new forwarding stuff
// LLB	1010
// LHB	1011
// addr = (Reg[ssss] & 0xFFFE) + (sign-extend(oooo) << 1).
module ALU(A, B, opcode, result, flagNV, flagZ, nvz_flags);
input [15:0] A;
input [15:0] B;
input [2:0] opcode;
input flagNV, flagZ;
output [15:0] result;
output [2:0] nvz_flags;

// Lest of wires for the result of each module
wire [15:0] ADDSUB_result, XOR_result, PADDSB_result, RED_result,
			SLL_result, SRA_result, ROR_result;
//Calculate all the NVZ flags, then only set the ones we actually should
wire [2:0] tempNVZ;

// ADD/SUB
// Sub or add is dictated by the opcode[0]
wire posOvfl, negOvfl, ifZero;
SATADDSUB_16bit iSAS16_0(.A(A), .B(B), .sub(opcode[0]), .Sum(ADDSUB_result), 
						.posOvfl(posOvfl), .negOvfl(negOvfl), .ifZero(ifZero));

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

// Assumes overflow set if it would've overflowed, because under current design, its
// impossible to overflow with saturated arithmetic
/*
The Z flag is set if and only if the output of the operation is zero. 
The V flag is set by the ADD and SUB instructions if and only if the operation results
in an overflow. Overflow must be set based on treating the arithmetic values as 16-bit 
signed integers.  
The N flag is set if and only if the result of the ADD or SUB instruction is negative.
*/
wire temp;
assign temp = ^XOR_result;

assign tempNVZ = (~opcode[2] & ~opcode[1]) ? {ADDSUB_result[15], (posOvfl | negOvfl), ifZero} :	// opcode = 00X
					(~opcode[2] & ~opcode[0]) ? {1'b0, 1'b0, (^XOR_result == 1'bX ? 1'b0 : XOR_result == 16'h0000)} : // opcode = 0X0
					(~opcode[2]) ? {1'b0, 1'b0, (RED_result == 16'h0000)} : // opcode = 0XX
					(~opcode[1] & ~opcode[0]) ?  {1'b0, 1'b0, (SLL_result == 16'h0000)} : // opcode = X00
					(~opcode[1]) ? {1'b0, 1'b0, (SRA_result == 16'h0000)} : // opcode = X0X
					(~opcode[0]) ? {1'b0, 1'b0, (ROR_result == 16'h0000)} : // opcode = XX0
					{1'b0, 1'b0, (PADDSB_result == 16'h0000)}; // last of the opcode possibilities 
assign nvz_flags = flagNV ? tempNVZ : flagZ ? {nvz_flags[2:1], tempNVZ[0]} : nvz_flags;

//assign nvz_flags = { ^result === 1'bx ? 1'b0 : result[15], (posOvfl | negOvfl) === 1'bx ? 1'b0 : (posOvfl | negOvfl) , ^result === 1'bx ? 1'b0 : result == 16'h0000 };


endmodule