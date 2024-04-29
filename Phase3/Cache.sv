module Cache(clk, rst, dataWE, metaWE, WordEnable, tag,
					data, blockSelect, write0, write1, tagOut0,
					tagOut1, dataOut0, dataOut1);

input clk, rst;
// write enable for data and meta
input dataWE, metaWE;
// Word enable and tag for metadata
input [7:0] WordEnable, tag;
// 16 bit port for writing to cache
input [15:0] data;
// Select which of the 64 blocks to choose (Note the modification in DataArray.sv, where we split it
// 2 sets of 64 blocks), so the WriteEnable0 and WriteEnable1 will do the choosing of the 2 blocks
input [63:0] blockSelect;
// Here selects which of the set to choose
input write0, write1;

// Data and Tag outputs
output [15:0] dataOut0, dataOut1;
output [7:0] tagOut0, tagOut1;

// Data portion of Cache
DataArray cache(.clk(clk), .rst(rst), .DataIn(data), .WriteEN0(write0 & dataWE), .WriteEN1(write1 & dataWE),  
	.BlockEnable(blockSelect), .WordEnable(WordEnable), .DataOut0(dataOut0), .DataOut1(dataOut1));

// Metadata for storing tags etc
MetaDataArray metadata(.clk(clk), .rst(rst), .DataIn(tag), .Write0(write0 & metaWE), .Write1(write1 & metaWE),  
	.BlockEnable(blockSelect), .DataOut0(tagOut0), .DataOut1(tagOut1));

endmodule