module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
input clk;		//Clock
input rst;		
input [3:0] SrcReg1;	//ID of SrcReg1 - goes into decoder
input [3:0] SrcReg2;	//ID of SrcReg1 - goes into decoder
input [3:0] DstReg;	//ID of DstReg - goes into decoder
input WriteReg;		//Controls whether WriteReg is enabled
input [15:0] DstData;	//Data to be loaded into written reg (if enabled)
inout [15:0] SrcData1;	//Can be output line for first read
inout [15:0] SrcData2;	//Can be output line for second read

//Internal signals
wire [15:0] ReadLine1;
wire [15:0] ReadLine2;
wire [15:0] WriteLine;
wire [15:0] srcLine1;
//1. INITIALIZE DECODERS
ReadDecoder_4_16 readDecoder1(.RegId(SrcReg1), .Wordline(ReadLine1));
ReadDecoder_4_16 readDecoder2(.RegId(SrcReg2), .Wordline(ReadLine2));
WriteDecoder_4_16 writeDecoder2(.RegId(DstData), .WriteReg(WriteReg), .Wordline(WriteLine));

//3. INITIALIZE REGISTERS
Register regArray[15:0] (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteLine), .ReadEnable1(ReadLine1), .ReadEnable2(ReadLine2), .Bitline1(srcLine1), .Bitline2(SrcData2));
endmodule


/* OLD CODE FOR REGISTERFILE
module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
input clk;		//Clock
input rst;		
input [3:0] SrcReg1;	//ID of SrcReg1 - goes into decoder
input [3:0] SrcReg2;	//ID of SrcReg1 - goes into decoder
input [3:0] DstReg;	//ID of DstReg - goes into decoder
input WriteReg;		//Controls whether WriteReg is enabled
input [15:0] DstData;	//Data to be loaded into written reg (if enabled)
inout [15:0] SrcData1;	//Can be output line for first read
inout [15:0] SrcData2;	//Can be output line for second read

//Internal signals
wire [15:0] ReadLine1;
wire [15:0] ReadLine2;
wire [15:0] WriteLine;
wire [15:0] srcLine1;
//1. INITIALIZE DECODERS
ReadDecoder_4_16 readDecoder1(.RegId(SrcReg1), .Wordline(ReadLine1));
ReadDecoder_4_16 readDecoder2(.RegId(SrcReg2), .Wordline(ReadLine2));
WriteDecoder_4_16 writeDecoder2(.RegId(DstData), .WriteReg(WriteReg), .Wordline(WriteLine));

//3. INITIALIZE REGISTERS
Register regArray[15:0] (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteLine), .ReadEnable1(ReadLine1), .ReadEnable2(ReadLine2), .Bitline1(srcLine1), .Bitline2(SrcData2));
endmodule
*/