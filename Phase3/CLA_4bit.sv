module CLA_4bit(
	input [3:0] A,
	input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);

// Propogate and generate, carry
wire P0, G0, P1, G1, P3, G3, C0, C1, C2, C3;

// Propogate only if 1 of them is high
assign P0 = A[0] ^ B[0];
assign P1 = A[1] ^ B[1];
assign P2 = A[2] ^ B[2];
assign P3 = A[3] ^ B[3];

// If both are high, then we for sure will generate
assign G0 = A[0] & B[0];
assign G1 = A[1] & B[1];
assign G2 = A[2] & B[2];
assign G3 = A[3] & B[3];

// Carries logic
// Basic idea: check if generate, if not check if all the previous generates/carry has a ladder
// of propogates it can follow on
/////////////////////////////////////////////////////////////////////////////////////
// I think it's better to copy and paste logic than to use older variables in newer
// Initially I put it more elegant and used C0 in C1, or C0 and C1 in C2. 
// If we did it like that, then it would have it syntehsize in series
// and slow it down. But if we copy and paste, it would synthesize in parallel and be faster
// overall (of course higher area but who cares lol).
assign C0 = G0 | (Cin & P0);
assign C1 = G1 | (G0 & P1) | (Cin & P0 & P1);
assign C2 = G2 | (G1 & P2) | (G0 & P1 & P2) | (Cin & P0 & P1 & P2);
assign C3 = G3 | (G2 & P3) | (G1 & P2 & P3) | (G0 & P1 & P2 & P3) | (Cin & P0 & P1 & P2 & P3);

// Cout is the last carry
assign Cout = C3;

// If it propagates and there's carry then it carries
// If only one is high of propagates or there's a carry then it sums
// If neither progagates or carry, then no carry and no sum
assign Sum[0] = P0 ^ Cin;
assign Sum[1] = P1 ^ C0;
assign Sum[2] = P2 ^ C1;
assign Sum[3] = P3 ^ C2;

endmodule