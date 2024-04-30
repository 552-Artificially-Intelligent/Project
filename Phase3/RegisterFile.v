///////////////////////////////////////////////////////////////////////
// Treat the last 4 bits as rt for ADD, PADDSB, SUB, XOR, RED
/*
!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!REGISTERFILE!!!!!!!!!!!!!!!!!!
INPUT:
	- .clk: Clock
	- .rst: reset 
	- .SrcReg1: first reg to be read, currently set to bits 7-4, unless doing LLB or LHB
	- .SrcReg2: second reg to be read, currently set to bits 3-0
	- .DstReg: register to be written to (if applicable)
	- .WriteReg: controls whether DstReg is written to, from Control 
	- .DstData: data to be written into DestReg - complicated logic
		-if instruction is LLB or LHB:
			- if LHB, set upper 8 bits - {[SrcData1[15:8], instruction[7:0]}
			- else (LLB), set lower 8 bits - {[SrcData1[15:8], instruction[7:0]}
		-else:
			- if MemtoReg is enabled, set it to data_out (output of data memory?)
			- else, set it to result (ALU result)
INOUT: 
	- .SrcData1: output from when SrcReg1 is read
	- .SrcData2: output from when SrcReg2 is read
*/
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
WriteDecoder_4_16 writeDecoder2(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(WriteLine));

//3. INITIALIZE REGISTERS
wire [15:0] imm1, imm2;
Register regArray[15:0] (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteLine), 
						.ReadEnable1(ReadLine1), .ReadEnable2(ReadLine2), .Bitline1(imm1), 
						.Bitline2(imm2));

assign SrcData1 = ~|SrcReg1 ? 16'h0000 : imm1;
assign SrcData2 = ~|SrcReg2 ? 16'h0000 : imm2;

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