module cacheTest();

  logic clk, rst, miss, memValid;
  reg [15:0] missAddr, memAddr;
  wire busy, tagEnable;
  integer vectors;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
   cache_fill_FSM myHandler (.clk(clk), .rst_n(rst), .miss_detected(miss), .miss_address(missAddr), .fsm_busy(busy),
   .memory_address(memAddr), .memory_data_valid(memValid));
  
  initial begin
    //Reset
    clk = 1'b0;
    rst = 1'b1;
    miss = 1'b0;
    /*
    5FF4 - 1110 1110 1110 0100
    TOTAL AMOUNT OF DATA IN ONE BLOCK: 16 BYTES
    111011101110 XXX 0
    ADDRESSES THAT SHOULD BE RETURNED:
    EEE0 (1110111011100000)
    EEE2 (1110111011100010)
    EEE4 (1110111011100100)
    EEE6 (1110111011100110)
    EEE8 (1110111011101000)
    EEEA (1110111011101010)
    EEEC (1110111011101100)
    EEEE (1110111011101110)
    */
    missAddr = 16'hEEE4;
    #50;
    clk = 1'b1;
    #50;
    clk = 1'b0;
    #50;
    clk = 1'b1;
    $display("RST: %b, ADDR: %h, MISS: %b || STORED ADDR: %h, CYCLES LEFT: %d, BUSY: %b", rst, missAddr, miss, myHandler.currentAddr, myHandler.cyclesLeft, myHandler.busy);
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
	$display("RST: %b, ADDR: %h, MISS: %b, VAL: %b || ADDR OUTPUT: %h, CYCLES LEFT: %d, BUSY: %b", rst, missAddr, miss, memValid, myHandler.currentAddr, myHandler.cyclesLeft, myHandler.busy);
	#50;
    	clk = 1'b1;
    	#50;
    	clk = 1'b0;
	memValid = 1'b1;
	$display("RST: %b, ADDR: %h, MISS: %b, VAL: %b || ADDR OUTPUT: %h, CYCLES LEFT: %d, BUSY: %b", rst, missAddr, miss, memValid, myHandler.currentAddr, myHandler.cyclesLeft, myHandler.busy);
	miss = 1'b0;
     end
	$stop();
  end
  
endmodule