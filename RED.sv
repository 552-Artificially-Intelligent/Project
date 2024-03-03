module RED(
	input [7:0] A,
	input [7:0] B,
	input [7:0] C,
	input [7:0] D,

	output [16:0] Sum_ABCD,
);
// Sum should be 16 bits since instructions say:
// the contents of rd will be the sign-extended 
// value of ((aaaaaaaa+cccccccc) + (bbbbbbbb+dddddddd)). 

// Idea: We will do double 8 bit addition with the 8bit CLAs
// Then we collect the Cout separately, so then we can use 1 more
// final 8bit CLA to add them. Then we figure out the 9th and 8th bit (assuming starts at bit0)
// using all the Couts we collect
wire [7:0] sumAB, sumCD, sumABCD;
wire Cout0, Cout1, Cout2;
wire bit8Layer1, bit8Layer2, bit8C, MSB;

CLA_8bit CLA8_0(.A(A), .B(B), .Cin(0), .Sum(sumAB), .Cout(Cout0));
CLA_8bit CLA8_0(.A(C), .B(D), .Cin(0), .Sum(sumCD), .Cout(Cout1));

// Add together AB and CD
CLA_8bit CLA8_0(.A(sumAB), .B(sumCD), .Cin(0), .Sum(sumABCD), .Cout(Cout2));
assign bit8Layer1 = Cout0 ^ Cout1;
assign bit8C = Cout0 & Cout1;

// Find the 9th and 8th bits (assuming bit starts at 0)
assign bit8Layer2 = (bit8Layer1 ^ Cout2);
assign MSB = bit8C | (bit8Layer1 & Cout2);

assign Sum_ABCD = {7{MSB}, bit8Layer2, sumABCD};

endmodule