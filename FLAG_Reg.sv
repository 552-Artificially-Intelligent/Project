module FLAG_reg(clk, rst_n, en, opcode, flags, N_flag, Z_flag, V_flag);

input clk, rst_n, en;
input [2:0] flags, opcode;
output N_flag, Z_flag, V_flag;
////////////////////////////////////////////////////////////

wire [2:0] flagOuputs;
// dff (q, d, wen, clk, rst)
// TODO: Check if it should preserve old value across other non ALU instruction
// or check if it should stay 0 while other non ALU instructions
BitReg regn (.Q(flagOuputs[2]), .D(flags[2]), .wen(en & (~|opcode[2:1])), .clk(clk), .rst(~rst_n));

BitReg regv (.Q(flagOuputs[1]), .D(flags[1]), .wen(en & (~|opcode[2:1])), .clk(clk), .rst(~rst_n));

BitReg regz (.Q(flagOuputs[0]), .D(flags[0]), .wen(en), .clk(clk), .rst(~rst_n));

// NVZ
assign N_flag = ~rst_n ? 1'b0 : flagOuputs[2];
assign V_flag = ~rst_n ? 1'b0 : flagOuputs[1];
assign Z_flag = ~rst_n ? 1'b0 : flagOuputs[0];

endmodule