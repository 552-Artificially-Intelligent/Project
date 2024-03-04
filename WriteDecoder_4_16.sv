module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);

wire [3:0] RDRegId;
wire [15:0] RDWordline;

ReadDecoder_4_16 RD4_16_0(.RegId(RDRegId), .Wordline(RDWordline));

assign Wordline = WriteReg ? RDWordline : 16'h0000;

endmodule