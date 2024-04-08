module Control(
    input [3:0] opcode, 
    output [2:0] ALUOp,
    output ALUsrc,
    output MemtoReg,
    output RegWrite,
    output MemRead,
    output MemWrite,
    output branch_inst,
    output branch_src,
    output RegDst,
    output PCs,
    output LoadPartial,
    output SavePC,
    output Hlt,
    output flagNV,
    output flagZ
);

assign Hlt = &opcode;
assign PCs = opcode == 4'b1110 ? 1'b1 : 1'b0;
assign branch_inst = opcode[3:1] == 3'b110 ? 1'b1 : 1'b0;
assign branch_src = opcode[0];

assign RegWrite = ~opcode[3] | (opcode[3] & ~|opcode[2:0]) | (opcode == 4'b1010) | (opcode == 4'b1011) | (&opcode[3:1] & ~opcode[0]);
assign RegDst = ~opcode[3] | opcode == 4'b1110 ? 1'b1 : 1'b0;
assign MemRead = opcode == 4'b1000 ? 1'b1 : 1'b0;
assign MemtoReg = opcode == 4'b1000 ? 1'b1 : 1'b0;
assign MemWrite = opcode == 4'b1001 ? 1'b1 : 1'b0;
assign LoadPartial = opcode[3:1] == 3'b101 ? 1'b1 : 1'b0;
assign SavePC = opcode == 4'b1110 ? 1'b1 : 1'b0;
assign flagNV = opcode[3:1] == 3'b000 ? 1'b1 : 1'b0;    //Only change on add and subtract (0000 and 0001)
assign flagZ = opcode[3] == 1'b0 & opcode[1:0] != 2'b11 ? 1'b1 : 1'b0;  //All functions beginning with "0" but RED and PADDSB can modify

assign ALUOp = ~opcode[3] ? opcode[2:0] : 3'b000;

assign ALUsrc = ~opcode[3] ? 
    (opcode[2] & ~&opcode[1:0] ? 1'b1 : 1'b0) : 
    1'b1;

endmodule