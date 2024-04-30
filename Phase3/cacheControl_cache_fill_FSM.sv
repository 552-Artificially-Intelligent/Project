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
assign currentMissInput = (busy | miss_detected) ? cyclesLeft[2] == 1'b1 ?
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
XXXX-XXXX-X000-0000	#111
XXXX-XXXX-X001-0000  	#110
XXXX-XXXX-X010-0000	#101
XXXX-XXXX-X011-0000	#100
XXXX-XXXX-X100-0000
XXXX-XXXX-X101-0000
XXXX-XXXX-X110-0000
XXXX-XXXX-X111-0000
*/
assign currentAddr = {miss_address[15:7], ~cyclesLeft, 4'b00000};
assign memory_address = currentAddr;

endmodule