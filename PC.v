module PC(
    input [15:0] next,
    input en,
    input rst_n,
    input clk,
    output [15:0] PC
);

wire [15:0] internalPC, blank;
// Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
Register reg0(
    .D(next),
    .WriteReg(en),
    .clk(clk),
    .ReadEnable1(1'b1),
    .rst(~rst_n),
    .Bitline1(internalPC),
    .ReadEnable2(1'b0),
    .Bitline2(blank)
);

assign PC = ~rst_n ? 16'h0000 : internalPC;
// clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1
endmodule