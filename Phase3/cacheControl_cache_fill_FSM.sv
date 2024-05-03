module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, 
	fsm_busy, memory_address, memory_data_valid, write_tag_array);
input clk, rst_n;
input miss_detected; // active high when tag match logic detects a miss
input [15:0] miss_address; // address that missed the cache
output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output [15:0] memory_address; // address to read from memory
output write_tag_array; // write enable to cachetag array to signal when all words are filled in to data array
input memory_data_valid; // active high indicates valid data returning on memory bus

//How many chunks do we have left to read?
wire[2:0] cyclesLeft;
logic[2:0] currentMissInput;
logic[15:0] currentAddr;
logic enableCyc;
// wire busy;

//BitReg to track when miss is detected
//Should only be possible to write to when a miss is detected AND when it's not already handling a miss
//Alternatively, when it is handling a miss and no cycles are left
//logic enableCur;
//assign enableCur = ~busy | (fsm_busy & !miss_detected) | miss_detected;
assign fsm_busy = miss_detected;

//Track whether or not a chunk was successfully read on the last cycle
//logic lastValid;
//BitReg currentMiss(.Q(lastValid), .D(~lastValid), .wen(memory_data_valid | lastValid), .clk(clk), .rst(rst_n));

/*
Burisma Joe Biden and his deep state friends have been destroying our multicycle memory, it's absolutely despicable. 
The memory_data_valid signal, or as i like to call it, the memory_data_INVALID signal, is one of the worst Verilog signals in our country's history.
Even the liberals are saying this. Everybody says it should only be high for one signal, then it should go down to zero. 
Does this happen though. No. The liberals, the conservatives, everyone are all googoo gaga, they're saying this is very bad. Going to break the FSM.
But Joe Ciminski, or as I like to call him, Coding Joe, wrote this very tremendous cycle counter. Every four cycles, it will tell the FSM to go up a number, it uses electrical wires to make our code work perfectly.
Coding Joe is almost as smart as I am! Nobody can compete with my genes. Did you all know my uncle, John Trump, very smart fellow, taught engineering at MIT? Runs in the family.
*/ 
wire[1:0] nextCount;
logic[1:0] curCount;
assign nextCount = (rst_n | !miss_detected) ? 2'b00 :
	curCount[1] == 1'b1 ? 
		curCount[0] == 1'b1 ? 2'b00 : 2'b11 : 	// 11 -> 00, 10 -> 11
		curCount[0] == 1'b1 ? 2'b10 : 2'b01;	// 01 -> 10, 00 -> 01
dff cycleCounter[1:0] (.q(curCount), .d(nextCount), .wen(fsm_busy | (!fsm_busy & curCount != 2'b00)), .clk(clk), .rst(rst_n));

/*
If not currently handling a miss, 0 chunks are left to read
Otherwise subtract 1 from the value
*/
assign currentMissInput = (rst_n) ? 3'b000 :
	(miss_detected) ? cyclesLeft[2] == 1'b1 ?		// If miss-detected goes to 0, this will reset cyclesLeft
	cyclesLeft[1] == 1'b1 ?
		cyclesLeft[0] == 1'b1 ? 3'b111 : 3'b111 :	// 111 -> 111, 110 -> 111
		cyclesLeft[0] == 1'b1 ? 3'b110 : 3'b101		// 101 -> 110, 100 -> 101
	: cyclesLeft[1] == 1'b1 ?
		cyclesLeft[0] == 1'b1 ? 3'b100 : 3'b011 :	// 011 -> 100, 010 - > 011
		cyclesLeft[0] == 1'b1 ? 3'b010 : 3'b001		// 001 -> 010, 000 -> 001
	: 3'b000;
//assign enableCyc = (fsm_busy & memory_data_valid) | (!fsm_busy & cyclesLeft != 3'b000);
assign enableCyc = (fsm_busy & curCount == 2'b10) | (!fsm_busy & cyclesLeft != 3'b000);
//assign enableCyc = fsm_busy | cyclesLeft != 3'b000;
dff cycleStore[2:0] (.q(cyclesLeft), .d(currentMissInput), .wen(enableCyc), .clk(clk), .rst(rst_n));

/*Output 16-bit address
XXXX-XXXX-XXXX-0000	#111
XXXX-XXXX-XXXX-0010  	#110
XXXX-XXXX-XXXX-0100	#101
XXXX-XXXX-XXXX-0110	#100
XXXX-XXXX-XXXX-1000	#011
XXXX-XXXX-XXXX-1010	#010
XXXX-XXXX-XXXX-1100	#001
XXXX-XXXX-XXXX-1110	#000
*/
assign currentAddr = {miss_address[15:4], cyclesLeft, 1'b0};
assign memory_address = miss_detected ? currentAddr : 16'h0000;
//THIS LINE CONTROLS 
assign write_tag_array = curCount == 2'b11 & cyclesLeft == 3'b111;


/////////////////////////////////////////////////////////
// Currently it looks like currAddr instatly goes to 000E, instead
// of incrementing every 4 cycles, so ill see if I can rewrite it. Joe usually
// has a night shift wednesdas so Ill try recreating it.
/////////////////////////////////////////////////////////

// Count up to 8: 0, 2, 4, 6, 8, 10, 12, 14
// Count up to 4 cycles, then "increment" add 4

// Theres 2 ways we can try this, 
// 1. we can either have 2 counter, one for the word
// and the other to count the 4 cycles
// 2. Or we can have a counter count up for 32 (8 * 4) cycles and then >> right shift
// by 2 or divide by 2 to get (or for the final result we >> 2, then << 1, to remove the last bit)
// wire [15:0] address;
// // We can just add up to 0111 and then shift by 1 to be multiples of 2
//////////////////////////////////////////////////////////////////////
// wire [15:0] address;
// // We can just add up to 0111 and then shift by 1 to be multiples of 2
// wire [3:0] block;
// wire [5:0] counter, counterShft;
// wire [7:0] sum;

// // 0 = idle, 1 = wait
// wire state, next_state;
// wire words_left;
// dff cycleStore[2:0](.clk(clk), .rst(rst_n), .wen(1'b1), .d(next_state), .q(state));
// assign next_state = state ? words_left : miss_detected;
// assign words_left = (state & (counter != 6'b10_0000));

// // output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
// // output [15:0] memory_address; // address to read from memory
// assign fsm_busy = state;

// // Address determinator
// assign counterShft = counter >> 2;
// assign block = counterShft[3:0];
// assign address = rst ? 16'b0 : {miss_address[15:4], block << 1};
// assign memory_address = address;

// dff cycleStore[5:0](.clk(clk), .rst(rst_n | (~state)), 
// 	.wen(1'b1), .d(sum[5:0]), .q(counter));
// CLA_8bit cla1(.A({2'b0, counter}), .B(1'b1), .Cin(1'b0), .Sum(sum), .Cout());







endmodule