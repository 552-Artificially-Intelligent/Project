// module SATADDSUB_16bit(
// 	input [15:0] A, 		// 4 bit A
// 	input [15:0] B, 		// 4 bit B
// 	input sub,			// Subtract or add
// 	output [15:0] Sum,	// 4 bit Sum
// );
module SATADDSUB_16bit(A, B, sub, Sum, posOvfl, negOvfl, ifZero);
input [15:0] A, B;
input sub;
output [15:0] Sum;
output posOvfl, negOvfl, ifZero;


// Prepare inputs if we subtract
wire [15:0] notB, inputB, tempSum;
assign notB = ~B;
// If sub is on, then we can put sub in Cin instead of using another FA to add 1 here
// Choose either if sub or add
assign inputB = sub ? notB : B;


wire Cout0, Cout1, Cout2, Cout3;
CLA_4bit CLA4_0(.A(A[3:0]), .B(inputB[3:0]), .Cin(sub), .Sum(tempSum[3:0]), .Cout(Cout0));
CLA_4bit CLA4_1(.A(A[7:4]), .B(inputB[7:4]), .Cin(Cout0), .Sum(tempSum[7:4]), .Cout(Cout1));
CLA_4bit CLA4_2(.A(A[11:8]), .B(inputB[11:8]), .Cin(Cout1), .Sum(tempSum[11:8]), .Cout(Cout2));
CLA_4bit CLA4_3(.A(A[15:12]), .B(inputB[15:12]), .Cin(Cout2), .Sum(tempSum[15:12]), .Cout(Cout3));

assign posOvfl = (~A[15] & ~B[15] & tempSum[15]);
assign negOvfl = (A[15] & B[15] & ~tempSum[15]);

// Figure out if we overflowed, and if so, saturate
assign Sum = posOvfl ? 16'h7FFF :
			negOvfl ? 16'h8000 : tempSum;

assign ifZero = (Sum == 16'h0000);

endmodule