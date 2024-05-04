
////////////////////////////////////////////
// Note: THis is not done and needs work TODO
////////////////////////////////////////////

module Data_Hazard_Detect(
	opcode, D_X_destination_reg, D_source_reg, 
	stall
);

// Assuming we have X to X forwarding, the only data hazard
// we need to watch out for is RAW - when it is a LW
// (since ALU instruction RAW is solved by forwarding)

input [3:0] opcode, D_X_destination_reg, D_source_reg;
output stall;

// If both D_source and D_X_deistanation register addresses are the same
// And there is a LW instruction, then stall
assign stall = (opcode == 4'h8) & (D_X_destination_reg == D_source_reg);

// TODO: Check when branches are resolved and maybe we need to check
// If branching is enabled or not


endmodule