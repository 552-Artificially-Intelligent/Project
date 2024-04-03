module Shifter_tb();

reg [15:0] Shift_In, Shift_Out;
reg [3:0] Shift_Val;
reg Mode;

Shifter iDUT(.Shift_Out(Shift_Out), .Shift_In(Shift_In), .Shift_Val(Shift_Val), .Mode(Mode));


initial begin

	Shift_In = 16'b0011_1011_1100_1010;
	Shift_Val = 10;
	Mode = 0;
	if (Shift_Out != Shift_In << 10)
		$display("Error Left shift");

	Shift_In = 16'b0011_1011_1100_1010;
	Shift_Val = 10;
	Mode = 1;
	if (Shift_Out != 16'b0000_0000_0000_1110)
		$display("Error Right shift");

	$display("All good");

end



endmodule