module cacheTest();

  logic clk, rst, miss, memValid;
  reg [15:0] missAddr, memAddr;
  wire busy, tagEnable;
  integer vectors;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
   cache_fill_FSM myHandler (.clk(clk), .rst_n(rst), .miss_detected(miss), .miss_address(missAddr), .fsm_busy(busy),
   .write_tag_array(tagEnable), .memory_address(memAddr), .memory_data_valid(memValid));
  
  initial begin
    //Reset
    clk = 1'b0;
    rst = 1'b1;
    // FF 
    missAddr = 16'hFFF4;
    #50;
    clk = 1'b1;
    #50;
    clk = 1'b0;
    #50;
    clk = 1'b1;
    #50;
    clk = 1'b0;
    rst = 1'b0;
    miss = 1'b1;
    #50;
    clk = 1'b1;
    #50;
    clk = 1'b0;
    //Actually test everything
    for (vectors=0; vectors<16; vectors++) begin
	#50;
    	clk = 1'b1;
    	#50;
    	clk = 1'b0;
	memValid = 1'b0;
	$display("CURRENT ADDRESS: %h - BUSY: %b", memAddr, busy);
	#50;
    	clk = 1'b1;
    	#50;
    	clk = 1'b0;
	memValid = 1'b1;
	$display("CURRENT ADDRESS: %h - BUSY: %b", memAddr, busy);
	miss = 1'b0;
     end
	$stop();
  end
  
endmodule