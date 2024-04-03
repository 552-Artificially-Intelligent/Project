module CLA_16bit(
	input [15:0] A,
	input [15:0] B,
    input Cin,
    output [15:0] Sum,
    output Cout
);

wire C0;

CLA_8bit CLA8_0(.A(A[7:0]), .B(B[7:0]), .Cin(Cin), .Sum(Sum[7:0]), .Cout(C0));
CLA_8bit CLA8_1(.A(A[15:8]), .B(B[15:8]), .Cin(C0), .Sum(Sum[15:8]), .Cout(Cout));


endmodule