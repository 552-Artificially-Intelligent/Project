module Forwarding_Unit(
	// Input Signals
	X_M_RegWrite, X_M_MemWrite, M_W_RegWrite, 

	// Input Data
	X_M_reg_dest, M_W_reg_dest, D_X_reg_source1, 
	D_X_reg_source2, X_M_reg_source2,

	// Output Signals
	EXtoEX_frwdA, EXtoEX_frwdB, MEMtoMEM_frwdB, 
	MEMtoEX_frwdA, MEMtoEX_frwdB

);

input X_M_RegWrite, X_M_MemWrite, M_W_RegWrite;
input [3:0] X_M_reg_dest, M_W_reg_dest, D_X_reg_source1, D_X_reg_source2, X_M_reg_source2;
output EXtoEX_frwdA, EXtoEX_frwdB, MEMtoMEM_frwdB, MEMtoEX_frwdA, MEMtoEX_frwdB;

// ==========================================================
// NOTE: Double check to make sure if they select reg 0, it always connects to 0/don't forward
// ==========================================================
// If X_M is writing to register and it matches the source
assign EXtoEX_frwdA = X_M_RegWrite 
						& (X_M_reg_dest == D_X_reg_source1) 
						& ~(D_X_reg_source1 == 4'h0);
assign EXtoEX_frwdB = X_M_RegWrite 
						& (X_M_reg_dest == D_X_reg_source2) 
						& ~(D_X_reg_source2 == 4'h0);

// If we are writing to memory and we previously is writing to reg and the reg isn't 
assign MEMtoMEM_frwdB = (X_M_MemWrite) & (M_W_RegWrite)	
						& (M_W_reg_dest == X_M_reg_source2)
						& ~(M_W_reg_dest == 4'h0);

// Check for if we are writngback 
assign MEMtoEX_frwdA = M_W_RegWrite
						& (M_W_reg_dest == D_X_reg_source1) 
						& ~(X_M_RegWrite & (X_M_reg_dest == D_X_reg_source1) & (X_M_reg_dest != 4'h0))
						& ~(M_W_reg_dest == 4'h0);
assign MEMtoEX_frwdB = M_W_RegWrite
						& (M_W_reg_dest == D_X_reg_source2) 
						& ~(X_M_RegWrite & (X_M_reg_dest == D_X_reg_source2) & (X_M_reg_dest != 4'h0))
						& ~(M_W_reg_dest == 4'h0);





endmodule