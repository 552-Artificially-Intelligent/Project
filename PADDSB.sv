module PADDSB(
	input [15:0] A,
	input [15:0] B,
	// PADDSUB will always be adding

	output [15:0] Sum
);

// Half bytes are MSB at the left
wire [3:0] tempHalfByte0, tempHalfByte1, tempHalfByte2, tempHalfByte3;
wire Cout0, Cout1, Cout2, Cout3;

CLA_4bit CLA4_0(.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(tempHalfByte0), .Cout(Cout0));
CLA_4bit CLA4_1(.A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Sum(tempHalfByte1), .Cout(Cout0));
CLA_4bit CLA4_2(.A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Sum(tempHalfByte2), .Cout(Cout0));
CLA_4bit CLA4_3(.A(A[15:12]), .B(B[15:12]), .Cin(1'b0), .Sum(tempHalfByte3), .Cout(Cout0));

// Figure out overflow
wire [3:0] posOvfl, negOvfl;
assign posOvfl[0] = (~A[3] & ~B[3] & tempHalfByte0[3]);
assign negOvfl[0] = (A[3] & B[3] & ~tempHalfByte0[3]);

assign posOvfl[1] = (~A[7] & ~B[7] & tempHalfByte1[7]);
assign negOvfl[1] = (A[7] & B[7] & ~tempHalfByte1[7]);

assign posOvfl[1] = (~A[11] & ~B[11] & tempHalfByte2[11]);
assign negOvfl[1] = (A[11] & B[11] & ~tempHalfByte2[11]);

assign posOvfl[1] = (~A[15] & ~B[15] & tempHalfByte3[15]);
assign negOvfl[1] = (A[15] & B[15] & ~tempHalfByte3[15]);

// Set if overflowe
assign Sum[3:0] = posOvfl[0] ? 4'b0111 :
				negOvfl[0] ? 16'b1000 : tempHalfByte0;
assign Sum[7:4] = posOvfl[1] ? 4'b0111 :
				negOvfl[1] ? 16'b1000 : tempHalfByte1;
assign Sum[11:8] = posOvfl[2] ? 4'b0111 :
				negOvfl[2] ? 16'b1000 : tempHalfByte2;
assign Sum[15:12] = posOvfl[3] ? 4'b0111 :
				negOvfl[3] ? 16'b1000 : tempHalfByte3;

endmodule