module ROR(
	input [15:0] Shift_In, 		// This is the input data to perform shift operation on
	input [3:0] Shift_Val, 		// Shift amount (used to shift the input data)
	output [15:0] Shift_Out, 	// Shifted output data
);

wire rbit0, rbit1, rbit2, rbit3;

assign rbit0 = Shift_Val[0] ? {Shift_In[0], Shift_In[15:1]} : Shift_In[15:0];
assign rbit1 = Shift_Val[1] ? {{2{rbit0[0:1]}}, rbit0[15:2]} : rbit0;
assign rbit2 = Shift_Val[2] ? {{4{rbit1[0:3]}}, rbit1[15:4]} : rbit1;
assign rbit3 = Shift_Val[3] ? {{8{rbit2[0:7]}}, rbit2[15:8]} : rbit2;

assign Shift_Out = rbit3;

endmodule