module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);

// Implement similar to shifter logic, where we read RegID bits
// And shift left by 1, 2, 4, 8 each time

wire [15:0] startVal, shiftBit0, shiftBit1, shiftBit2, shiftBit3;

assign startVal = 16'h0001;

assign shiftBit0 = RegId[0] ? (startVal << 1) : startVal;
assign shiftBit1 = RegId[1] ? (shiftBit0 << 2) : shiftBit0;
assign shiftBit2 = RegId[2] ? (shiftBit0 << 4) : shiftBit1;
assign shiftBit3 = RegId[3] ? (shiftBit0 << 8) : shiftBit3;

// Is a bit redundant to use shiftBit3, but since it should synthesize the same, 
// and I like how it separates out, I'll keep it as is
assign Wordline = shiftBit3;

endmodule