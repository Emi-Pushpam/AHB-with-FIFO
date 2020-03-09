module fifo_ahbif #(parameter DWIDTH = 32,
	                parameter AWIDTH = 18,
                    parameter DEPTH=1<<AWIDTH) 
  
              // Global signals
  
              (hclk, 
               hreset, 
 
               // AHB slave 
  
               hsel, 
               haddr, 
               hburst, 
               htrans, 
               hrdata, 
               hwdata, 
               hwrite, 
               hready, 
               hresp, 
 
               // FIFO interface 
  
               rdata,
  			   wdata,
  			   wen, 
  			   wclk,
  			   wrst,
  			   ren,
  			   rclk,
  			   rrst,
  			   waddr, 
  			   raddr);

  // Global signals
  
input               hclk;            
input               hreset;
  
//AHB slave interface 
  
input               hsel; 
input  	  [31:0]    haddr; 
input     [2:0]     hburst; 
input     [1:0]     htrans; 
input     [31:0]    hwdata; 
input               hwrite; 
  
output    [1:0]     hresp; 
output    [31:0]    hrdata; 
output              hready_out;
  
  
//FIFO interface 
  
  input     [DWIDTH-1:0]    rdata; 
  output    [AWIDTH-1:0]    waddr,raddr; 
  output    [DWIDTH-1:0]    wdata; 
  output             	    fifowr,fiford;
  wire      [1:0]           hresp;
  wire      [DWIDTH-1:0]    hrdata; 
  reg                       hready;
 
  wire      [DWIDTH-1:0]    wdata; 
  reg       [AWIDTH-1:0]    waddr,raddr; 
  reg                	    fifowr;
  reg				        fiford;  
 
  wire                wen; 
  wire                ren;
  wire                ready_en; 

assign hresp_s = 2'b00; 
 
always@(posedge hclk or negedge hreset) 
begin  
  if(!hreset) begin 
    waddr <= {18{1'b0}};
    raddr <= {18{1'b0}};
  end 
  else if (hsel == 1'b1) begin 
    waddr <= haddr[19:2]; 
    raddr <= haddr[19:2]; 
  end 
end 
 
assign wen = hsel & htrans[1] & hwrite; 
assign ren = hsel & htrans[1] & !hwrite; 
 
always@(posedge hclk or negedge hreset) 
begin 
  if(!hreset) begin 
    fifowr <= 1'b0; 
  end else if(wen) begin 
    fifowr <= 1'b1; 
  end else begin 
    fifowr <= 1'b0; 
  end 
end 

  always@(posedge hclk or negedge hreset) 
begin 
  if(!hreset) begin 
    fiford <= 1'b0; 
  end else if(ren) begin 
    fiford <= 1'b1; 
  end else begin 
    fiford <= 1'b0; 
  end 
end 
  
assign wdata = hwdata; 
 
assign hrdata= rdata; 
 
assign ready_en = hsel & htrans[1]; 
 
always@(posedge hclk or negedge hreset) 
begin 
  if(!hreset) begin 
    hready <= 1'b0; 
  end else if(ready_en) begin 
    hready <= 1'b1; 
  end else begin 
    hready <= 1'b0; 
  end 
end 
  
endmodule