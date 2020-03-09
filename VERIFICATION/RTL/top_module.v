module top( 
               hclk, 
               hreset, 
               hsel,
               haddr, 
               hburst, 
               htrans, 
               hrdata, 
               hwdata, 
               hwrite, 
               hready, 
               hresp, 
  			   fifowr,
               fiford,
               wclk,
               rclk,
               wrst,
               rrst,
               rdata,
               wdata); 
 
input               hclk;
input               hreset; 
input               hsel;
input     [19:0]    haddr; 
input     [2:0]     hburst; 
input     [1:0]   	htrans; 
input     [31:0]  	hwdata; 
input               hwrite; 
input				wrst;
input				rrst;
output              rdata;
input				wdata;
 
output    [1:0]     hresp; 
output    [31:0]    hrdata; 
output              hready; 
  
reg                 rclk;
wire				wclk;
  
wire      [DWIDTH-1:0]    	rdata; 
wire      [AWIDTH-1:0]  	waddr,raddr; 
wire      [DWIDTH:0]    	wdata; 
wire                		fifowr,fiford;
 
fifo_ahbif u_fifo_ahbif( 
               .hclk(hclk), 
               .hreset(hreset), 
               .hsel(hsel), 
               .haddr(haddr), 
               .hburst(hburst), 
               .htrans(htrans), 
               .hrdata(hrdata), 
               .hwdata(hwdata), 
               .hwrite(hwrite), 
               .hready(hready), 
               .hresp(hresp), 
               .rdata(rdata), 
               .waddr(waddr),
               .raddr(raddr),
               .wdata(wdata), 
  			   .fifowr(fifowr) 
               .fiford(fiford)
                 ); 
  
  assign wclk=hclk;
  always@(posedge hclk)
    begin
      rclk=~rclk; 
    end
 
		asyn_fifo U_asyn_fifo( 
 			 .fifowr(fifowr),
 			 .wclk(wclk), 
  			 .wrst(wrst),
 			 .rdata(rdata),
 			 .wdata(wdata),
 			 .fiford(fiford),
  			 .rclk(rclk),
 			 .rrst(rst)
             .wrst(wrst)); 
 
endmodule
