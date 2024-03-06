module Shifter(Shift_Out, Shift_In, Shift_Val, Mode);

input [15:0] Shift_In; 		// This is the input data to perform shift operation on
input [3:0] Shift_Val; 		// Shift amount (used to shift the input data)
input  Mode; 				// To indicate 0=SLL or 1=SRA 
output [15:0] Shift_Out; 	// Shifted output data


wire [15:0] lbit0, lbit1, lbit2, lbit3, rbit0, rbit1, rbit2, rbit3;
// Idea/Inspiration is to use software case statements, where if there's no breaks
// it can cascade down and run each case block after it
assign lbit0 = Shift_Val[0] ? Shift_In << 1 : Shift_In;
assign lbit1 = Shift_Val[1] ? lbit0 << 2 : lbit0;
assign lbit2 = Shift_Val[2] ? lbit1 << 4 : lbit1;
assign lbit2 = Shift_Val[3] ? lbit1 << 8 : lbit2;

assign rbit0 = Shift_Val[0] ? {Shift_In[15], Shift_In[15:1]} : Shift_In[15:0];
assign rbit1 = Shift_Val[1] ? {{2{rbit0[15]}}, rbit0[15:2]} : rbit0;
assign rbit2 = Shift_Val[2] ? {{4{rbit1[15]}}, rbit1[15:4]} : rbit1;
assign rbit3 = Shift_Val[3] ? {{8{rbit2[15]}}, rbit2[15:8]} : rbit2;

assign Shift_Out = Mode ? rbit3 : lbit3;

endmodule