/*	=== CODE FOR REGISTERS === 	*/
module dff (q, d, wen, clk, rst);

    output         q; //DFF output
    input          d; //DFF input
    input 	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 1'b0 : (wen ? d : state);
    end

endmodule

module BitReg(clk, rst, wen, D, Q);
input clk, rst, wen, D;
output Q;

wire interQ;

dff flop0(.q(interQ), .clk(~clk), .d(D), .wen(wen), .rst(rst));
dff flop1(.d(interQ), .clk(~clk), .q(Q), .wen(wen), .rst(rst));

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
// assign Bitline1 = ReadEnable1 ? dffOut : 1'bz;
// assign Bitline2 = ReadEnable2 ? dffOut : 1'bz;
assign Bitline1 = ReadEnable1 ? (WriteEnable ? D : dffOut) : 1'bz;
assign Bitline2 = ReadEnable2 ? (WriteEnable ? D : dffOut) : 1'bz;

endmodule

module BitCell2(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
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
assign Bitline1 = ReadEnable1 ? dffOut : 1'bz;
assign Bitline2 = ReadEnable2 ? dffOut : 1'bz;
// assign Bitline1 = ReadEnable1 ? (WriteEnable ? D : dffOut) : 1'bz;
// assign Bitline2 = ReadEnable2 ? (WriteEnable ? D : dffOut) : 1'bz;

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

module Register2(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

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