interface inf(input bit clk);
  
	logic	hclk;
	logic   hreset; 
	logic   hsel;
	logic	[19:0]	haddr; 
  	logic	[2:0]	hburst; 
	logic	[1:0]	htrans; 
	logic	[31:0]	hwdata; 
	logic	hwrite; 
	logic	wrst;
	logic	rrst;
	logic	rdata;
	logic	wdata;
 
  	logic	[1:0]	hresp; 
	logic	[31:0]	hrdata; 
	logic	hready; 
  
endinterface
