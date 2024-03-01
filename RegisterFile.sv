// Gokul's D-flipflop
//Thank you Goku, very cool!

module dff (q, d, wen, clk, rst);

    output         q; //DFF output
    input          d; //DFF input
    input 	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 0 : (wen ? d : state);
    end

endmodule

module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
input clk;		//Goes in D
input rst;		//Goes in D
input D;		//Goes in D
input WriteEnable;	//"wen" in D
input ReadEnable1;	//I think these select which Bitline to use?
input ReadEnable2;	//??
inout Bitline1;		//Used to send out output (I think)
inout Bitline2;		//??

//Initialize D flip flop
wire dffOut;
dff floppy(.q(dffOut), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

//Tristate buffers
assign Bitline1 = ReadEnable1 ? (WriteEnable ? D : dffOut) : 1'bz;
assign Bitline2 = ReadEnable2 ? (WriteEnable ? D : dffOut) : 1'bz;

endmodule

module ReadDecoder_4_16(RegId, Wordline);
input [3:0] RegId;
output [15:0] Wordline;

	//I think this is correct
	assign Wordline[15] = RegId[3] && RegId[2] && RegId[1] && RegId[0];
	assign Wordline[14] = RegId[3] && RegId[2] && RegId[1] && !RegId[0];
	assign Wordline[13] = RegId[3] && RegId[2] && !RegId[1] && RegId[0];
	assign Wordline[12] = RegId[3] && RegId[2] && !RegId[1] && !RegId[0];
	assign Wordline[11] = RegId[3] && !RegId[2] && RegId[1] && RegId[0];
	assign Wordline[10] = RegId[3] && !RegId[2] && RegId[1] && !RegId[0];
	assign Wordline[9] = RegId[3] && !RegId[2] && !RegId[1] && RegId[0];
	assign Wordline[8] = RegId[3] && !RegId[2] && !RegId[1] && !RegId[0];
	assign Wordline[7] = !RegId[3] && RegId[2] && RegId[1] && RegId[0];
	assign Wordline[6] = !RegId[3] && RegId[2] && RegId[1] && !RegId[0];
	assign Wordline[5] = !RegId[3] && RegId[2] && !RegId[1] && RegId[0];
	assign Wordline[4] = !RegId[3] && RegId[2] && !RegId[1] && !RegId[0];
	assign Wordline[3] = !RegId[3] && !RegId[2] && RegId[1] && RegId[0];
	assign Wordline[2] = !RegId[3] && !RegId[2] && RegId[1] && !RegId[0];
	assign Wordline[1] = !RegId[3] && !RegId[2] && !RegId[1] && RegId[0];
	assign Wordline[0] = !RegId[3] && !RegId[2] && !RegId[1] && !RegId[0];	
endmodule

module WriteDecoder_4_16(RegId, WriteReg, Wordline);
input [3:0] RegId;
input WriteReg;
output [15:0] Wordline;

	//If WriteReg is false, disable all Wordlines
	assign Wordline[15] = RegId[3] && RegId[2] && RegId[1] && RegId[0] && WriteReg;
	assign Wordline[14] = RegId[3] && RegId[2] && RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[13] = RegId[3] && RegId[2] && !RegId[1] && RegId[0] && WriteReg;
	assign Wordline[12] = RegId[3] && RegId[2] && !RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[11] = RegId[3] && !RegId[2] && RegId[1] && RegId[0] && WriteReg;
	assign Wordline[10] = RegId[3] && !RegId[2] && RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[9] = RegId[3] && !RegId[2] && !RegId[1] && RegId[0] && WriteReg;
	assign Wordline[8] = RegId[3] && !RegId[2] && !RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[7] = !RegId[3] && RegId[2] && RegId[1] && RegId[0] && WriteReg;
	assign Wordline[6] = !RegId[3] && RegId[2] && RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[5] = !RegId[3] && RegId[2] && !RegId[1] && RegId[0] && WriteReg;
	assign Wordline[4] = !RegId[3] && RegId[2] && !RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[3] = !RegId[3] && !RegId[2] && RegId[1] && RegId[0] && WriteReg;
	assign Wordline[2] = !RegId[3] && !RegId[2] && RegId[1] && !RegId[0] && WriteReg;
	assign Wordline[1] = !RegId[3] && !RegId[2] && !RegId[1] && RegId[0] && WriteReg;
	assign Wordline[0] = !RegId[3] && !RegId[2] && !RegId[1] && !RegId[0] && WriteReg;	
endmodule

module Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk;
input rst;
input [15:0] D;		//Data to write to register
input WriteReg;
input ReadEnable1;
input ReadEnable2;
inout [15:0] Bitline1;
inout [15:0] Bitline2;

//Create 15 BitCells
//clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2); 
//Dff (.q(whatever_output_is), .d(Bitline1), .wen(WriteReg), .clk(clk), .rst(rst))
//Get D's output (D.d)
BitCell bitArray[15:0] (.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));

endmodule

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