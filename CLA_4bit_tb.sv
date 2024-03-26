module CLA_4bit_tb();

reg [3:0] A, B;
reg Cin;

wire [3:0] Sum;
wire Cout;

CLA_4bit iDUT(.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));

reg [4:0] expectedSum;

integer i;

initial begin

	A = 4'b0000;
	B = 4'b0000;
	Cin = 0;
	#5

	for (i = 0; i < 32; i++) begin
		A = (i % 2 == 0) ? A + 1 : A;
		B = (i % 2 == 1) ? B + 1 : B;
		Cin = (i % 3 == 0) ? 1 : 0;

		expectedSum = A + B + Cin;
		#5

		if ({Cout, Sum} != expectedSum) begin
			$display("Failed Adding: ", A, B, "Expected: ", expectedSum);
		end
	end

	$display("Everything good!");
	$stop();

end


endmodule