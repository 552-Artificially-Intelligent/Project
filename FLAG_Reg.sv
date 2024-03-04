module FLAG_reg(clk, rst_n, flags, N_flag, Z_flag, V_flag));

input clk, rst_n;
input [2:0] flags;
output N_flag, Z_flag, V_flag;
////////////////////////////////////////////////////////////

wire [2:0] flagOuputs;
Register reg(
    .D(flags),
    .WriteReg(1'b1),
    .clk(clk),
    .ReadEnable1(1'b1),
    .rst(rst_n),
    .Bitline1(flagOuputs)
);

assign N_flag = flagOuputs[2];
assign Z_flag = flagOuputs[1];
assign V_flag = flagOuputs[0];

endmodule