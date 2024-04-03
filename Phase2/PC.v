module PC(
    input [15:0] next,
    input en,
    input rst_n,
    input clk,
    output [15:0] PC
);

wire [15:0] internalPC1, blank1, internalPC2, blank2;
// Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
Register reg0(
    .D(next),
    .WriteReg(en & ~clk),
    .clk(~clk),
    .ReadEnable1(1'b1),
    .rst(~rst_n),
    .Bitline1(internalPC1),
    .ReadEnable2(1'b0),
    .Bitline2(blank1)
);

Register reg1(
    .D(internalPC1),
    .WriteReg(en & clk),
    .clk(clk),
    .ReadEnable1(1'b1),
    .rst(~rst_n),
    .Bitline1(internalPC2),
    .ReadEnable2(1'b0),
    .Bitline2(blank2)
);

assign PC = ~rst_n ? 16'h0000 : (&internalPC2 ? 16'hFFFF : internalPC2);
// clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1
endmodule