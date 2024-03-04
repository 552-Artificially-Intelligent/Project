module PC(
    input [15:0] next,
    input en,
    input rst_n,
    input clk,
    output [15:0] PC
);

Register reg0(
    .D(next),
    .WriteReg(en),
    .clk(clk),
    .ReadEnable1(1'b1),
    .rst(rst_n),
    .Bitline1(PC)
);
// clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1
endmodule