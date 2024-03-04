module FLAG_reg(clk, rst_n, flags, N_flag, Z_flag, V_flag);

input clk, rst_n;
input [2:0] flags;
output N_flag, Z_flag, V_flag;
////////////////////////////////////////////////////////////

wire [2:0] flagOuputs;
// dff (q, d, wen, clk, rst)
dff dff0 [2:0](.q(flagOuputs), .d(flags), .wen(1'b1), .clk(clk), .rst(rst_n));

// NVZ
assign N_flag = flagOuputs[2];
assign V_flag = flagOuputs[1];
assign Z_flag = flagOuputs[0];

endmodule