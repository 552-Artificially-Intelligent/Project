//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

module MetaDataArray(input clk, input rst, input [7:0] DataIn, input Write0, input Write1,  
	input [63:0] BlockEnable, output [7:0] DataOut0, output [7:0] DataOut1);

	// Again split the cache like the data array into 2 separate 64 blocks

	// TODO: The one 1 bit LRU logic here
	// Tag sent in composed of (6 bit tag, read, write)
	// Tag sent out/stored here:
	// Bit 7:2 (6 bits) tag bits
	// bit 1 LRU (so data in we pass in read/write)
	// Bit 0 Valid Bit (if there's anything inside or not) 
	// Ok so we will have 2 bits (1 from each block), to determine which is oldest

	wire valid, LRU;
	assign valid = Write0 | Write1;
	assign LRUChange = valid & (DataIn[1] | DataIn[0])
	wire [7:0] storedTag;
	assign storedTag = {DataIn[7:2], LRUChange, valid};


	MBlock Mblk[63:0]( .clk(clk), .rst(rst), .Din(storedTag), 
		.WriteEnable(Write0), .Enable(BlockEnable), .Dout(DataOut));

	MBlock Mblk[63:0]( .clk(clk), .rst(rst), .Din(storedTag), 
		.WriteEnable(Write1), .Enable(BlockEnable), .Dout(DataOut));

endmodule

module MBlock( input clk,  input rst, input [7:0] Din, input WriteEnable, input Enable, output [7:0] Dout);
	// Bit [5:0]
	MCell mcTag[5:0]( .clk(clk), .rst(rst), .Din(Din[7:2]), .WriteEnable(WriteEnable), 
		.Enable(Enable), .Dout(Dout[7:2]));
	// We only need 6 bits for tag, so we can do custom inputs for the last 2 bits

	// Since only one of the blocks (Write0 or Write1) is enabled at a time (as well as obviously BlockEnable), 
	// and if LRUChange is enabled, then we need make 1 block the LRU and the other the MRU
	// So the last written block will be the MRU (output 0), and the other is LRU (output 1).
	// Note we do not want to input WriteEnabel for the LRU into WriteEnable, because
	// we need all blocks to adjust value when new write.
	// Edit: Initially I had .Din(~WriteEnable | ~Enable), but then I remembered splitting it into
	// 64 blockSelect instead of 128, so then Ill just make it only ~WriteEnable
	// Yea in hindsight I think I shouldve kept the blocks back to 128, but fuck it whatever its too
	// late lol. Fuck this shit im out lol
	// Bit 7
	MCell mcLRU(.clk(clk), .rst(rst), .Din(~WriteEnable), .WriteEnable(Din[1]), 
		.Enable(Enable), .Dout(Dout[1]));

	// So the valid will initially be 0, and once there's something put inside it, it will then
	// permanetly stay as 1
	// Bit 6
	MCell mcValid(.clk(clk), .rst(rst), .Din(1'b1), .WriteEnable(Din[0] & WriteEnable), 
		.Enable(Enable), .Dout(Dout[0]));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

