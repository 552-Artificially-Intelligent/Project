// module ROR(
// 	input [15:0] Shift_In, 		// This is the input data to perform shift operation on
// 	input [3:0] Shift_Val, 		// Shift amount (used to shift the input data)
// 	output [15:0] Shift_Out, 	// Shifted output data
// );
module ROR(Shift_In, Shift_Val, Shift_Out);
input [15:0] Shift_In; 		// This is the input data to perform shift operation on
input [3:0] Shift_Val; 		// Shift amount (used to shift the input data)
output [15:0] Shift_Out; 	// Shifted output data

wire [15:0] rorbit0, rorbit1, rorbit2, rorbit3;

// assign rorbit0 = Shift_Val[0] ? {Shift_In[0], Shift_In[15:1]} : Shift_In[15:0];
// assign rorbit1 = Shift_Val[1] ? {rorbit0[1], rorbit0[0], rorbit0[15:2]} : rorbit0;
// assign rorbit2 = Shift_Val[2] ? {rorbit1[3], rorbit1[2], rorbit1[1], rorbit1[0], 
// 								rorbit1[15:4]} : rorbit1;
// assign rorbit3 = Shift_Val[3] ? {rorbit2[7], rorbit2[6], rorbit2[5], rorbit2[4],
// 								rorbit2[3], rorbit2[2], rorbit2[1], rorbit2[0],
// 								rorbit2[15:8]} : rorbit2;
assign rorbit0 = Shift_Val[0] ? {Shift_In[0], Shift_In[15:1]} : Shift_In[15:0];
assign rorbit1 = Shift_Val[1] ? {rorbit0[1:0], rorbit0[15:2]} : rorbit0;
assign rorbit2 = Shift_Val[2] ? {rorbit1[3:0], rorbit1[15:4]} : rorbit1;
assign rorbit3 = Shift_Val[3] ? {rorbit2[7:0], rorbit2[15:8]} : rorbit2;

assign Shift_Out = rorbit3;

endmodule