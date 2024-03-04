module CPU(clk, rst_n, hlt, pc);
input clk, rst_n, hlt;
output [15:0] pc;

////////////////////////////////////////////////////

// Instantiate the Instruction memory.v module
   // output  [15:0] data_out;
   // input [15:0]   data_in;
   // input [ADDR_WIDTH-1 :0]   addr;
   // input          enable;
   // input          wr;
   // input          clk;
   // input          rst;
wire [15:0] data_out, data_in, addr;
wire en, wr;
memory1c (.data_out(data_out), .data_in(data_in), .addr(addr), 
			.enable(en), .wr(wr), .clk(clk), .rst(rst_n));

PC pc0(.clk(clk), .en(en), .next(next), .PC(PC));





assign pc = hlt ? 16'h0000 : pc;

endmodule