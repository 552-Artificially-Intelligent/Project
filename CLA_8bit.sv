module CLA_8bit(
	input [7:0] A,
	input [7:0] B,
    input Cin,
    output [7:0] Sum,
    output Cout
);

wire C0;

CLA_4bit CLA4_0(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .Sum(Sum[3:0]), .Cout(C0));
CLA_4bit CLA4_1(.A(A[7:4]), .B(B[7:4]), .Cin(C0), .Sum(Sum[7:4]), .Cout(Cout));


endmodule