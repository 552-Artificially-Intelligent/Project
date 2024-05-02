module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, memory_address, memory_data_valid);
input clk, rst_n;
input miss_detected; // active high when tag match logic detects a miss
input [15:0] miss_address; // address that missed the cache
output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output [15:0] memory_address; // address to read from memory
input memory_data_valid; // active high indicates valid data returning on memory bus

//How many chunks do we have left to read?
wire[2:0] cyclesLeft;
logic[2:0] currentMissInput;
logic[15:0] currentAddr;
logic enableCur, enableCyc;
wire busy;

//BitReg to track when miss is detected
//Should only be possible to write to when a miss is detected AND when it's not already handling a miss
//Alternatively, when it is handling a miss and no cycles are left
assign enableCur = ~busy | (fsm_busy & cyclesLeft == 3'b000) | miss_detected;
BitReg currentMiss(.Q(busy), .D(miss_detected), .wen(enableCur), .clk(clk), .rst(rst_n));
assign fsm_busy = busy;

//Track whether or not a chunk was successfully read on the last cycle
//logic lastValid;
//BitReg currentMiss(.Q(lastValid), .D(~lastValid), .wen(memory_data_valid | lastValid), .clk(clk), .rst(rst_n));


/*
If not currently handling a miss, 0 chunks are left to read
Otherwise subtract 1 from the value
*/
assign currentMissInput = (rst_n) ? 3'b000 :
	(busy | miss_detected) ? cyclesLeft[2] == 1'b1 ?
	cyclesLeft[1] == 1'b1 ?
		cyclesLeft[0] == 1'b1 ? 3'b110 : 3'b101 :	// 111, 110
		cyclesLeft[0] == 1'b1 ? 3'b100 : 3'b011		// 101, 100
	: cyclesLeft[1] == 1'b1 ?
		cyclesLeft[0] == 1'b1 ? 3'b010 : 3'b001 :	// 011, 110
		cyclesLeft[0] == 1'b1 ? 3'b000 : 3'b111		// 001, 000
	: 3'b000;
assign enableCyc = fsm_busy & (currentMissInput == 3'b111 | memory_data_valid);
BitReg cycleStore[2:0] (.Q(cyclesLeft), .D(currentMissInput), .wen(enableCyc), .clk(clk), .rst(rst_n));

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
assign currentAddr = {miss_address[15:4], ~cyclesLeft, 1'b0};
assign memory_address = miss_detected ? currentAddr : 16'h0000;


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
// wire [3:0] block;
// wire [6:0] counter, counterShft;

// // 0 = idle, 1 = wait
// wire state;
// wire next_state;

// assign counterShft = counter >> 2;
// assign block = counterShft[3:0];
// assign address = rst ? 16'b0 : {miss_address[15:4], block << 1};
// assign memory_address = address;

// dff
// CLA_4bit cla0(.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));
// CLA_4bit cla1(.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));







endmodule