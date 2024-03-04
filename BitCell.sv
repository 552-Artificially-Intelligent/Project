module BitCell( input clk,  input rst, input D, input WriteEnable, 
	input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);

wire q;
dff dff0(.d(D), .q(q), .wen(WriteEnable), .rst(rst), .clk(clk));

assign Bitline1 = ~ReadEnable1 ? 1'bz : 
					WriteEnable ? D : q;
assign Bitline2 = ~ReadEnable2 ? 1'bz : 
					WriteEnable ? D : q;

endmodule