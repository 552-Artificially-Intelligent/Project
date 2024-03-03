module PC(
    input [15:0] next,
    input en,
    input clk,
    output [15:0] PC
);

Register reg(
    .D(next),
    .WriteReg(en),
    .clk(clk),
    .ReadEnable1(1'b1),
    .rst(1'b0),
    .Bitline1(PC)
);
// clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1
endmodule