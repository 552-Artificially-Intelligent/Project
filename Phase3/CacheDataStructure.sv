// Moved the CacheData Module to the top because I don't like to scroll down just to reference it
// over and over again.
// Total Cache Capacity is 2KB or 2^11, so it can contain 2^(11 - 4) = 2^7 words or 128 words
// or 16 blocks, we can subdivide it to 4 sets with 4 blocks in each set (for now until we figure
// how we want to store the addresses) 
module CacheData(clk, rst, D, WriteEnable, OutEnable, SetSelect, Q);

input clk, rst;
input [15:0] D;
input [2:0] WriteEnable, OutEnable;
input [1:0] SetSelect;
output [15:0] Q;

wire [3:0] setNum;
Decoder_2_4 Dec_2_4_0(.addr(SetSelect), .Word(setNum));

CacheBlock CB_0(.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteEnable & setNum[0]), 
				.OutEnable(OutEnable & setNum[0]), .Q(Q));
CacheBlock CB_1(.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteEnable & setNum[1]), 
				.OutEnable(OutEnable & setNum[1]), .Q(Q));
CacheBlock CB_2(.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteEnable & setNum[2]), 
				.OutEnable(OutEnable & setNum[2]), .Q(Q));
CacheBlock CB_3(.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteEnable & setNum[3]), 
				.OutEnable(OutEnable & setNum[3]), .Q(Q));

endmodule

module CacheBit(clk, rst, D, WriteEnable, OutEnable, Q);

input clk, rst, D, WriteEnable, OutEnable;
output Q;

wire q;

dff dff0(.clk(clk), .rst(rst), .wen(WriteEnable), .d(D), .q(q));

// We need this to open high impedance so we can have multiple outputs hit a single wire, and with all else 
assign Q = OutEnable ? q : 1'bz;

endmodule

module CacheWord(clk, rst, D, WriteEnable, OutEnable, Q);
// Each word is 16 bit
input clk, rst, WriteEnable, OutEnable;
input [15:0] D;
output [15:0] Q;

CacheBit cb0[15:0] (.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteEnable), .OutEnable(OutEnable), .Q(Q));

endmodule

// Block size is 16 B or 8 words
module CacheBlock(clk, rst, D, WriteEnable, OutEnable, Q);

input clk, rst;
input [15:0] D;
input [2:0] WriteEnable, OutEnable;
output [15:0] Q;

// Since we have to have only register chosen, we can either have 8 bits with one bit high to select the word
// Or we input a number 0 to 7, and use a decoder.
// input clk, rst;
// input [15:0] D;
// input [7:0] WriteEnable, OutEnable;
// output [15:0] Q;
// Check https://stackoverflow.com/questions/11111136/wire-high-if-exactly-one-high-in-verilog
// from Cliff Cumming, which looks like the guy Hoffman made us read
// wire zeroOrOnehot, atLeastOneBitSet, exactlyOneActive;
// wire [7:0] OneHighOrNone, OutEnableMOne;
// CLA_8bit CLA8_0(.A(OutEnable), .B(8'hFF), .Cin(1'b0), .Sum(OutEnableMOne), .Cout());
// assign zeroOrOnehot     = ~|(OutEnable & (OutEnableMOne));
// assign atLeastOneBitSet = |OutEnable;
// assign exactlyOneActive = zeroOrOnehot & atLeastOneBitSet;
// assign OneHighOrNone = exactlyOneActive ? OutEnable : {8{1'b0}}

// IMPOSTANT NOTE: For now I'll move the dcoder here, but when we test syntehsis and timing, we can
// choose either one for better efficiency. Note that for syntehsis we are not obligated to use
// verilog rules. Above I moved the what if implmentation in the comment above
wire [7:0] we, oe;
Decoder_3_8 decode0(.addr(WriteEnable), .Word(we));
Decoder_3_8 decode1(.addr(OutEnable), .Word(oe));

CacheWord cw0[7:0] (.clk(clk), .rst(rst), .D(D), .WriteEnable(we), .OutEnable(oe), .Q(Q));

endmodule

module Decoder_3_8(addr, Word);

input [2:0] addr;
output [7:0] Word;

wire [7:0] placeholder0, placeholder1, placeholder2;
// Here we implement similar to shifting logic
assign placeholder0 = addr[0] ? {8'b0000_0010} : {8'b0000_0001};
assign placeholder1 = addr[1] ? placeholder0 << 2 : placeholder0;
assign placeholder2 = addr[2] ? placeholder1 << 4 : placeholder1;

assign Word = placeholder2;

endmodule

module Decoder_2_4(addr, Word);

input [1:0] addr;
output [3:0] Word;

wire [3:0] placeholder0, placeholder1;
// Here we implement similar to shifting logic
assign placeholder0 = addr[0] ? {4'b0010} : {4'b0001};
assign placeholder1 = addr[1] ? placeholder0 << 2 : placeholder0;

assign Word = placeholder1;

endmodule



