module RegisterFile_TB();

  logic clk;		//Clock
  logic rst;		
  logic [3:0] SrcReg1;	//ID of SrcReg1 - goes into decoder
  logic [3:0] SrcReg2;	//ID of SrcReg1 - goes into decoder
  logic [3:0] DstReg;	//ID of DstReg - goes into decoder
  logic WriteReg;		//Controls whether WriteReg is enabled
  logic [15:0] DstData;	//Data to be loaded into written reg (if enabled)
  wire [15:0] SrcData1;	//Can be output line for first read
  wire [15:0] SrcData2;	//Can be output line for second read
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  RegisterFile iDUT (.clk(clk), .rst(rst), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(WriteReg), .DstData(DstData), .SrcData1(SrcData1), .SrcData2(SrcData2));  
  initial begin
    WriteReg = 1'b0;
    clk = 1'b0;
    SrcReg1 = 4'b0000;
    SrcReg1 = 4'b0001;
    DstReg = 4'b0010;
    DstData = 16'b0000000000000000;
    rst = 1'b1;
    #5;
    clk = 1'b1;
    #5;
    clk = 1'b0;
	
    end
  
endmodule