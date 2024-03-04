module ALU_tb();

reg [15:0] A, B, ph;
reg [2:0] opcode;
reg [15:0] expectRes;
wire [15:0] result;
reg [3:0] ph0, ph1, ph2, ph3;

ALU iDUT(.A(A), .B(B), .opcode(opcode), .result(result));

initial begin

	// Test all ADD/SUB
	A = 16'h0000;
	B = 16'h0000;
	opcode = 3'b000;
	for (int i = 0; i < 16'hFFFFF; ++i) begin
		A = (i % 2 == 0) ? A + 1 : A;
		B = (i % 2 == 1) ? B + 1 : B;

		opcode = 3'b000;
		// expectRes = A + B;
		// if (expectRes >= $signed(32767)) begin
		// 	expectRes = 16'h7FFF;
		// end 
		// else if (expectRes <= $signed(-32768)) begin
		// 	expectRes = 16'h8000;
		// end
		#4
		if (result != A + B) begin
			$display("Failed ADD", result, expectRes);
			$stop();
		end
		if (A + B > 32767) begin
            assert(result == 32767) else $error("Saturation not detected for A=%d, B=%d", A, B);
        end else if (A + B < $signed(-32768) begin
            assert(result == -32768) else $error("Saturation not detected for A=%d, B=%d", A, B);
        end else begin
            assert(result == A + B) else $error("Incorrect result for A=%d, B=%d", A, B);
        end

		opcode = 3'b001;
		expectRes = A - B;
		// if (expectRes >= $signed(32767)) begin
		// 	expectRes = 16'h7FFF;
		// end
		// else if (expectRes <= $signed(-32768)) begin
		// 	expectRes = 16'h8000;
		// end
		#4
		if (result != A - B) begin
			$display("Failed SUB");
			$stop();
		end
		if (A - B > 32767) begin
            assert(result == 32767) else $error("Saturation not detected for A=%d, B=%d", A, B);
        end else if (A - B < $signed(-32768)) begin
            assert(result == -32768) else $error("Saturation not detected for A=%d, B=%d", A, B);
        end else begin
            assert(result == A - B) else $error("Incorrect result for A=%d, B=%d", A, B);
        end
	end
	// $display("ADD/SUB Pass!");

	// Test XOR
	A = 16'h0000;
	B = 16'h0000;
	opcode = 3'b010;
	for (int i = 0; i < 17'hFFFFF; ++i) begin
		A = (i % 2 == 0) ? A + 1 : A;
		B = (i % 2 == 1) ? B + 1 : B;

		expectRes = A ^ B;
		#4
		if (result != expectRes) begin
			$display("Failed XOR");
			$stop();
		end
	end
	// $display("XOR Pass!");

	// Test PADDSB
	A = 16'h0000;
	B = 16'h0000;
	opcode = 3'b111;
	for (int i = 0; i < 17'hFFFFF; ++i) begin
		A = (i % 2 == 0) ? A + 1 : A;
		B = (i % 2 == 1) ? B + 1 : B;

		if ($signed(A[3:0] + B[3:0]) > $signed(4'b0111)) begin
			ph0 = 4'b0111;
		end
		else if ($signed(A[3:0] + B[3:0]) < $signed(4'b1000)) begin
			ph0 = 4'b1000;
		end
		else begin
			ph0 = A[3:0] + B[3:0];
		end

		if ($signed(A[7:4] + B[7:4]) > $signed(4'b0111)) begin
			ph1 = 4'b0111;
		end
		else if ($signed(A[7:4] + B[7:4]) < $signed(4'b1000)) begin
			ph1 = 4'b1000;
		end
		else begin
			ph1 = A[7:4] + B[7:4];
		end

		if ($signed(A[11:8] + B[11:8]) > $signed(4'b0111)) begin
			ph3 = 4'b0111;
		end
		else if ($signed(A[11:8] + B[11:8]) < $signed(4'b1000)) begin
			ph3 = 4'b1000;
		end
		else begin
			ph2 = A[11:8] + B[11:8];
		end

		if ($signed(A[15:12] + B[15:12]) > $signed(4'b0111)) begin
			ph3 = 4'b0111;
		end
		else if ($signed(A[15:12] + B[15:12]) < $signed(4'b1000)) begin
			ph3 = 4'b1000;
		end
		else begin
			ph3 = A[15:12] + B[15:12];
		end


		expectRes = {ph3, ph2, ph1, ph0};
		#4
		if (result != expectRes) begin
			$display("Failed PADDSB");
			$stop();
		end
	end
	// $display("PADDSB Pass!");


	// Test RED
	A = 16'h0000;
	B = 16'h0000;
	opcode = 3'b011;
	for (int i = 0; i < 17'hFFFFF; ++i) begin
		A = (i % 2 == 0) ? A + 1 : A;
		B = (i % 2 == 1) ? B + 1 : B;

		expectRes = ((A[15:8] + A[7:0]) + (B[15:8] + B[7:0]));
		#4
		if (result != expectRes) begin
			$display("Failed RED");
			$stop();
		end
	end
	// $display("RED Pass!");

	// Test SLL/SRA
	A = 16'h0000;
	B = 16'h0000;
	opcode = 3'b000;
	for (int i = 0; i < 17'hFFFFF; ++i) begin
		A = (i % 2 == 0) ? A + 1 : A;
		B = (i % 16);

		opcode = 3'b100;
		expectRes = {A << B[3:0]};
		#4
		if (result != expectRes) begin
			$display("Failed SLL");
			$stop();
		end

		opcode = 3'b101;
		expectRes = {A >>> B[3:0]};
		#4
		if (result != expectRes) begin
			$display("Failed SRA");
			$stop();
		end
	end
	// $display("SLL/SRA Pass!");

	// Test ROR
	A = 16'b0011_1011_1100_1010;
	B = 16'h0005;
	opcode = 3'b110;
	#4
	expectRes = 16'b010100011_1011_110;
	if (result != expectRes) begin
		$display("Failed ROR");
		$stop();
	end
	// $display("ROR Pass!");

	$display("All Pass!");
	$stop();

end

endmodule