module CacheModule(clk, rst, readInstruction, writeInstruction, readData, writeData, 
					instr_addr, data_addr, cacheInputData, F_stall, M_stall, 
					instr_miss, data_miss, instr_cache_data, memory_cache_data);

input clk, rst;
input readInstruction, writeInstruction, readData, writeData;
input [15:0] instr_addr, data_addr;
// Actual data the cache is receiving from memory/instr etc
input [15:0] cacheInputData;

// Stall fetch or memory stage
output F_stall, M_stall;
// output instr_hit, data_hit;
output instr_miss, data_miss;
output [15:0] instr_cache_data, memory_cache_data;

// Signals
// It looks like the FSM only enables if a miss is detected so maybe, if its reading/writing
// then it needs to enable through the miss detected

// FSM Data and Signals
wire enableCacheInstr, enableCacheData, enableCache, FSM_busy, FSM_memory_valid, FSM_write_tag_array;
wire [15:0] miss_address, memory_address;

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
// VERY IMPORTANT NOTE: I've just realized that I made the
// memory output called: memory_data_out, but I also made
// data cache outputs memory_data_out0, memory_data_out1
// Note this differences, I know I fucked the names but be
// careful when editing/debugging
wire [15:0] memory_data_out;
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

// Format: 
// [15:10] (6 bits) Tag (Remember in MetaData.sv 2 bits for LRU choosing)
// [9:4] (6 bits) For Block Index
// [2:0] for Word Select
// TODO: I've just realized too late, I should've kept it to 128 instead of 64, but it might be
// too late to change everything.

// Data for the decoder
wire [63:0] instr_block, data_block;
wire [7:0] miss_word, memory_word;
// Decoder for the Block Index
Decoder6_64 instBlock0(.addr(miss_address[15:10]), .block(instr_block));
Decoder6_64 dataBlock0(.addr(miss_address[15:10]), .block(data_block));

// Decoder for the Word Index
// memory_address comes from the FSM, so that the it flips through
// 0, 2, 4, 6, 8, 10, 12, 14
Decoder_3_8 instWord0(.addr(miss_address[3:1]), .word(miss_word));
Decoder_3_8 dataWord0(.addr(memory_address[3:1]), .word(memory_word));

// NOTE: storedTag = {DataIn[7:2], LRUChange, valid}; in metadata
// Instruction Cache
// Since Instructions should only come from memory (AKA we dont write new instructions)
// we can directly pass in the data.
wire [15:0] instr_CacheData, data_CacheData;
assign instr_CacheData = memory_data_out;
assign data_CacheData = data_miss ? memory_data_out : cacheInputData;
wire [15:0] instr_data_out0, instr_data_out1, memory_data_out0, memory_data_out1;
wire [7:0] instr_tag_out0, instr_tag_out1, data_tag_out0, data_tag_out1;
wire [7:0] instr_delay_out0, instr_delay_out1, data_delay_out0, data_delay_out1;
// Determine which of the 2 blocks to replace
wire instr_write0, instr_write1, data_write0, data_write1;
wire instr_writeLRU0, instr_writeLRU1, data_writeLRU0, data_writeLRU1; 
// Compare to bit 0 of metadata tag
// LRU bit is at bit 1
// Cache miss
// Bit 7:2 (6 bits) tag bits
// bit 1 LRU (so data in we pass in read/write)
// Bit 0 Valid Bit (if there's anything inside or not) 
// assign instr_write0 = (instr_addr[9:4] == instr_tag_out0[7:2]) 
// 						& instr_tag_out0[0];
// assign instr_write1 = (instr_addr[9:4] == instr_tag_out1[7:2]) 
// 						& instr_tag_out1[0];
// assign data_write0 = (data_addr[9:4] == data_tag_out0[7:2])
// 						& data_tag_out0[0];
// assign data_write1 = (data_addr[9:4] == data_tag_out1[7:2])
// 						& data_tag_out1[0];
assign instr_write0 = (instr_addr[9:4] == instr_delay_out0[7:2]) 
						& instr_delay_out0[0];
assign instr_write1 = (instr_addr[9:4] == instr_delay_out1[7:2]) 
						& instr_delay_out1[0];
assign data_write0 = (data_addr[9:4] == data_delay_out0[7:2])
						& data_delay_out0[0];
assign data_write1 = (data_addr[9:4] == data_delay_out1[7:2])
						& data_delay_out1[0];
/////////////////////////////////////////////////////////////////////
// First check if the cache block is valid, and then check if it's the LRU
	// If its, not valid, then just write at block0 first
	// It is important for the second write not to turn on if first one is on
wire [7:0] i_tagSel0, i_tagSel1, d_tagSel0, d_tagSel1;
assign i_tagSel0 = FSM_write_tag_array ? 8'h00 : instr_tag_out0;
assign i_tagSel1 = FSM_write_tag_array ? 8'h00 : instr_tag_out1;
assign d_tagSel0 = FSM_write_tag_array ? 8'h00 : data_tag_out0;
assign d_tagSel1 = FSM_write_tag_array ? 8'h00 : data_tag_out1;
dff delay0[7:0](.clk(clk), .rst(rst), .wen(1'b1), .d(i_tagSel0), .q(instr_delay_out0));
dff delay1[7:0](.clk(clk), .rst(rst), .wen(1'b1), .d(i_tagSel1), .q(instr_delay_out1));
dff delay2[7:0](.clk(clk), .rst(rst), .wen(1'b1), .d(d_tagSel0), .q(data_delay_out0));
dff delay3[7:0](.clk(clk), .rst(rst), .wen(1'b1), .d(i_tagSel1), .q(data_delay_out1));

// THis one under here dont use ever
// assign instr_delay_out0 = i_tagSel0;
// assign instr_delay_out1 = i_tagSel1;
// assign data_delay_out0 = d_tagSel0;
// assign data_delay_out1 = i_tagSel1;

// assign instr_writeLRU0 = instr_tag_out0[0] == 0 ? 1'b1 : instr_tag_out0[1];
// assign instr_writeLRU1 = ~instr_writeLRU0 & (instr_tag_out1[0] == 0 ? 1'b1 : instr_tag_out1[1]);
// assign data_writeLRU0 = data_tag_out0[0] == 0 ? 1'b1 : data_tag_out0[1];
// assign data_writeLRU1 = ~data_writeLRU0 & (data_tag_out1[0] == 0 ? 1'b1 : data_tag_out1[1]);
assign instr_writeLRU0 = instr_delay_out0[0] == 0 ? 1'b1 : instr_delay_out0[1];
assign instr_writeLRU1 = ~instr_writeLRU0 & (instr_delay_out1[0] == 0 ? 1'b1 : instr_delay_out1[1]);
assign data_writeLRU0 = data_delay_out0[0] == 0 ? 1'b1 : data_delay_out0[1];
assign data_writeLRU1 = ~data_writeLRU0 & (data_delay_out1[0] == 0 ? 1'b1 : data_delay_out1[1]);
// Since we are prioritizing instruction cache first, then we should have the enables on the miss
// as instr_miss, and the dataCache as ~instr_miss & data_miss 
// Need some flops to delay signal
	// At the very beginiing there is an cycle, in which miss detection uses the metadata
	// then the miss detection is sent to FSM, which then turns on the metadata to come out
	// Which means if one part of it becomes indeterminant, everything become indeterminant
	// And so we need some flops to delay it
// Do something with the word Enable but using the miss flops logic
Cache instrCache0(.clk(clk), .rst(rst), 
	.dataWE(writeInstruction | instr_miss), 
	.metaWE(FSM_write_tag_array), 
	.WordEnable(miss_word), 
	.tag({instr_addr[15:10], readInstruction, writeInstruction}), 
	.data(instr_CacheData), 
	.blockSelect(instr_block), 
	.write0(~rst & (instr_write0 | instr_writeLRU0)), 
	.write1(~rst & (instr_write1 | instr_writeLRU1)), 
	.tagOut0(instr_tag_out0),
	.tagOut1(instr_tag_out1), 
	.dataOut0(instr_data_out0), 
	.dataOut1(instr_data_out1), 
	.miss(instr_miss)
);

// Data Cache
Cache dataCache0(.clk(clk), .rst(rst), 
	.dataWE(writeData | data_miss), 
	.metaWE(FSM_write_tag_array), 
	.WordEnable(miss_word), 
	.tag({data_addr[15:10], readData, writeData}), 
	.data(data_CacheData), 
	.blockSelect(data_block), 
	.write0(~rst & (data_write0 | data_writeLRU0)), 
	.write1(~rst & (data_write1 | data_writeLRU1)), 
	.tagOut0(data_tag_out0),
	.tagOut1(data_tag_out1), 
	.dataOut0(memory_data_out0), 
	.dataOut1(memory_data_out1), 
	.miss(data_miss)
);





// Cache FSM
// Make sure to pass in rst, looks like the dff used in the FSM uses rst instead of rst_n
assign enableCacheInstr = readInstruction | writeInstruction;
assign enableCacheData = readData | writeData;
assign enableCache = enableCacheInstr | enableCacheData;
// Hit or Miss Detection
// Main cache miss detection is at ~(instr_write0 | instr_write1)
// For ~(instr_write0 | instr_write1) to be true, it means that the 12 bits of the 16 bit
// addresses didnt have a match, or if it did have a match it was empty
// (For example, "1010_10"00_0000_XXXX exists at initial, but is empty)
assign instr_miss = enableCacheInstr & ~(instr_write0 | instr_write1);
assign data_miss = enableCacheData & ~(data_write0 | data_write1);
// Hits signals are outputted
// assign instr_hit = enableCacheInstr & ~instr_miss;
// assign data_hit = enableCacheData & ~data_miss;
// Posting my discord message so I dont forget the logic again lol:
/*
Which would completely ignore the say the first instruction address 0000
So like lets say at the very beginning we retrieve the first instruction and make a 
cache miss, with the miss address as 0000
Then the first block it should import the addresses:
0000
0002
0004
0006
0008
000A
000C
000E
Ok yeah I think I figure it down a bit better
So I need to change the miss detection logic,so with say the 16 bit address h0000 or 0000_0000_0000_0000
"0000_00"00_0000_0000 determines which of the 64 slots to put
0000_00"00_0000"_0000 is the 6 bits stored into the meta data
0000_0000_0000_"0000" and these 8 addresses 0, 2, 4, 6, 8, 10, 12, 14 are stored
So there is a cache miss if the attempt address is equal to the 12 bits
"0000_0000_0000"_0000
Talk about sleep deprived high lol
*/
// NOTE: The miss_address here should be the arbitration for selecting which to do if there
// is both instruction and data miss. By checking instr_miss first, it prioritizes instruction
// fetches over data fetching. The reason why I choose instruction over data is because all 
// instructions need to be fetched, but not all instructions are memory instructions.
wire missHold, missDetect, instrMissHold;
wire [15:0] miss_AddrHold;
wire delayTag1, delayTag2, delayTag3, FSM_write_tag_array1C; // delayTag4
// dff addressHelper(.clk(clk), .rst(rst), .wen(FSM_write_tag_array1C | ~missHold), 
// 	.d(instr_miss), .q(instrMissHold));
// assign miss_address = instrMissHold ? instr_addr : data_addr;
assign instrMissHold = instr_miss;
assign miss_address = instrMissHold ? instr_addr : data_addr;
assign missDetect = ~rst & ((instr_miss | data_miss) & enableCache);
// Doing  | ~missDetect at the wen should allow it to only hold the value if there was a miss
// If there wasn't a miss, it will not hold and easily allow it to transition to miss
dff missHoledrAddr[15:0](.clk(clk), .rst(rst), .wen(FSM_write_tag_array), 
	.d(miss_address), .q(miss_AddrHold));
// dff missHoledrSig(.clk(clk), .rst(rst), .wen(FSM_write_tag_array | ~missHold), 
// 	.d(missDetect), .q(missHold));
assign missHold = missDetect;

// Delay write_tag_array from updating everything
dff delayTagWrite1(.clk(clk), .rst(rst), .wen(1'b1), 
	.d(delayTag), .q(delayTag1));
dff delayTagWrite2(.clk(clk), .rst(rst), .wen(1'b1), 
	.d(delayTag1), .q(delayTag2));
dff delayTagWrite3(.clk(clk), .rst(rst), .wen(1'b1), 
	.d(delayTag2), .q(delayTag3));
dff delayTagWrite4(.clk(clk), .rst(rst), .wen(1'b1), 
	.d(delayTag3), .q(FSM_write_tag_array));
dff delayTagWrite5(.clk(clk), .rst(rst), .wen(1'b1), 
	.d(FSM_write_tag_array), .q(FSM_write_tag_array1C));

cache_fill_FSM cache_FSM(.clk(clk), .rst_n(rst), 
	.miss_detected(missHold), 
	.miss_address(miss_AddrHold), .fsm_busy(FSM_busy),
	.memory_address(memory_address), 
	.memory_data_valid(FSM_memory_valid), 
	.write_tag_array(delayTag)
);

// 4 Cycle Memory
// Note: We have to make sure that there is only one 4 cycle memory instance going on so that
// we can properly implement the cache retrieving the instruction or the memory
// (data_out, data_in, addr, enable, wr, clk, rst, data_valid);
/////////////////////////////////////////////////////////
memory4c mainMemory(.data_out(memory_data_out), .data_in(cacheInputData), .addr(memory_address), 
	.enable(instr_miss | data_miss), .wr(writeData & ~FSM_busy), 
	.clk(clk), .rst(rst), .data_valid(FSM_memory_valid));


// Set outputs
// FSM_busy
assign F_stall = (FSM_busy & enableCacheInstr) | missHold;
assign M_stall = (FSM_busy & enableCacheData) | missHold;

// So if stall is high, it should always return 0s (well technically we can make it
// return the random stuff, but we would have to trust that if it is stalling, then it is
// not using the gibberish in the CPU) 
assign instr_cache_data = FSM_busy | ~FSM_memory_valid ? 16'h0000 : 
							(instr_write0 | instr_writeLRU0) ? instr_data_out0
							: instr_data_out1;
assign memory_cache_data = FSM_busy | ~FSM_memory_valid ? 16'h0000 : 
							(data_write0 | data_writeLRU0) ? memory_data_out0
							: memory_data_out1;




endmodule

// Do a simple shifter logic on decoder
module Decoder_3_8(addr, word);
	input [2:0] addr;
	output [7:0] word;

	wire [7:0] shift0, shift1, shift2;

	assign shift0 = addr[0] ? 8'b0000_0010 : 8'b0000_0001;
	assign shift1 = addr[1] ? shift0 << 2 : shift0;
	assign shift2 = addr[2] ? shift1 << 4 : shift1;

	assign word = shift2;

endmodule

module Decoder6_64(addr, block);
	input [5:0] addr;
	output [63:0] block;

	wire [63:0] shift0, shift1, shift2, shift3, shift4, shift5;

	assign shift0 = addr[0] ? 64'h0000_0000_0000_0002 : 64'h0000_0000_0000_0001;
	assign shift1 = addr[1] ? shift0 << 2 : shift0;
	assign shift2 = addr[2] ? shift1 << 4 : shift1;
	assign shift3 = addr[3] ? shift2 << 8 : shift2;
	assign shift4 = addr[4] ? shift3 << 16 : shift3;
	assign shift5 = addr[5] ? shift4 << 32 : shift4;

	assign block = shift5;
endmodule





