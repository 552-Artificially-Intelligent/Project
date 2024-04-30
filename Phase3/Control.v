/*
!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!CONTROL!!!!!!!!!!!!!!!!!!
INPUT:
    - .opcode: instruction[15:12]
OUTPUT: 
    - .ALUOp: ALU operation to be performed
    - .ALUsrc: set to 1 if anything besides SrcReg2 is to be used as the 2nd ALU operation
    - .MemtoReg: controls whether value to write comes from data memory (1) or ALU (0)
    - .RegWrite: controls whether WriteReg is written to
    - .MemRead: should control whether Memory is read; does nothing in practice (BUG???)
    - .MemWrite: controls whether Memory is written to
    - .branch_inst: whether the instruction is branch or not
    - .branch_src: whether to use jump value or branch value for PC
    - .RegDst: should be used to determine which value to write to register, currently unused (BUG???)
    - .PCs: whether PCS instruction is executed (saves PC value)
    - .LoadPartial: set to 1 if doing LLB or LHB, set to 0 otherwise
    - .SavePC: set to 1 if PCS instruction is being executed, set to 0 otherwise
    - .Hlt: whether to halt program (only if OPCODE = 1111)
*/
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
                    (opcode[2] & ~&opcode[1:0] ? 
                    1'b1 : 
                    1'b0) : 
                1'b1;

endmodule