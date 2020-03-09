module top #(parameter DWIDTH = 32,
	         parameter AWIDTH = 32,
             parameter DEPTH=1<<AWIDTH)
  
              (hclk, 
               hreset, 
               hsel,
               haddr, 
               hburst, 
               htrans, 
               hrdata, 
               hwdata,
               hsize,
               hmastlock,
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
               wdata,
               wfull,
               rempty); 
 
input               hclk;
input               hreset; 
input               hsel;
input     [31:0]    haddr; 
input     [2:0]     hburst; 
input     [1:0]   	htrans; 
input     [31:0]  	hwdata; 
  input     [2:0]    hsize;
input               hmastlock;
input               hwrite; 
input				wrst;
input				rrst;
input               rdata;
output				wdata;
output              wfull,rempty;
 
output    [1:0]     hresp; 
output    [31:0]    hrdata; 
output              hready; 
output    reg       fifowr,fiford;
  
output reg               rclk;
input wire				 wclk;
  
wire      [DWIDTH-1:0]    	rdata; 
wire      [AWIDTH-1:0]  	waddr,raddr; 
  wire      [DWIDTH-1:0]    	wdata; 

 
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
               .fifowr(fifowr), 
               .fiford(fiford),
                .hsize(hsize),
               .hmastlock(hmastlock)); 
  
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
          .rrst(rrst),
          .wfull(wfull),
             .rempty(rempty)); 
 endmodule





module fifo_ahbif #(parameter DWIDTH = 32,
	                parameter AWIDTH = 32,
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
               hsize,
               hmastlock,
 
               // FIFO interface 
  
               rdata,
  			   wdata,
  			   fifowr, 
  			   fiford,
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
  input     [2:0]     hsize;
input               hmastlock;
  
output    [1:0]     hresp; 
output    [31:0]    hrdata; 
output              hready;
  
  
//FIFO interface 

input     [31:0]    rdata;
output              fiford;
output   [31:0]    raddr;
  output    [31:0]    waddr;
output    [31:0]    wdata;
output              fifowr;

 
  
  wire      [1:0]           hresp;
  wire      [DWIDTH-1:0]    hrdata; 
  reg                       hready;
 
  wire      [DWIDTH-1:0]    wdata; 
  reg       [AWIDTH-1:0]    waddr,raddr; 
  reg                	    fifowr;
  reg		                fiford;  
 
  wire                wen; 
  wire                ren;
  wire                ready_en; 

assign hresp = 2'b00; 
 
always@(posedge hclk or negedge hreset) 
begin  
  if(!hreset) begin 
    waddr <= {AWIDTH{1'b0}};
    raddr <= {AWIDTH{1'b0}};
  end 
  else if (hsel == 1'b1) begin 
    waddr <= haddr[AWIDTH-1:2]; 
    raddr <= haddr[AWIDTH-1:2]; 
  end 
end 
 
assign wen = hsel & htrans[1] & hwrite; 
assign ren = hsel & htrans[1] & !hwrite; 
 
always@(posedge hclk or negedge hreset) 
begin 
  if(!hreset) begin 
    fifowr <= 1'b0; 
  end else if(wen)begin 
    fifowr <= 1'b1; 
  end 
  else 
     fifowr <= 1'b0;
end 

  always@(posedge hclk or negedge hreset) 
begin 
  if(!hreset) begin 
    fiford <= 1'b0;  
  end else if(ren) begin 
    fiford <= 1'b1; 
  end 
  else
     fiford <= 1'b0;
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






module asyn_fifo #(parameter DWIDTH = 32,
	       parameter AWIDTH = 32,
	       parameter DEPTH=1<<AWIDTH)
	      (output 	reg   [DWIDTH-1:0]	rdata,
	       output				wfull,
	       output   			rempty,
	       input	      [DWIDTH-1:0]	wdata,
	       input				fifowr, wclk, wrst,
	       input				fiford, rclk, rrst);

wire	[AWIDTH-1:0] 	waddr, raddr;
  wire	[AWIDTH:0] 	wptr, rptr, wclk2_rptr, rclk2_wptr;

  sync_rw	sync_rw	(.wclk2_rptr(wclk2_rptr), 
		.rptr(rptr),
		.wclk(wclk), 
		.wrst(wrst));

  sync_wr	sync_wr	(.rclk2_wptr(rclk2_wptr), 
		.wptr(wptr),
		.rclk(rclk), 
		.rrst(rrst));

fifo_mem #(DWIDTH, AWIDTH) fifo_mem
		(.rdata(rdata), .wdata(wdata),
		.waddr(waddr), .raddr(raddr),
		.wclken(fifowr), .wfull(wfull),
                .wclk(wclk));

rptr_empty #(AWIDTH) rptr_empty
		(.rempty(rempty),
		.raddr(raddr),
		.rptr(rptr), 
               .rclk2_wptr(rclk2_wptr),
		.fiford(fiford), .rclk(rclk),
		.rrst(rrst));

wptr_full #(AWIDTH) wptr_full
		(.wfull(wfull), .waddr(waddr),
                .wptr(wptr), .wclk2_rptr(wclk2_rptr),
		.fifowr(fifowr), .wclk(wclk),
		.wrst(wrst));

endmodule


module fifo_mem #(parameter DWIDTH = 32,
		 parameter AWIDTH = 32,
                parameter DEPTH=1<<AWIDTH)
(output [DWIDTH-1:0] rdata, 
 input	[DWIDTH-1:0] wdata,
 input	[AWIDTH-1:0] waddr, raddr,
 input	wclken, wfull, wclk);


reg [DWIDTH-1:0] mem [0:DEPTH-1];

assign rdata = mem[raddr]; 
  
always @(posedge wclk)
if (wclken && !wfull) 
  mem[waddr] <= wdata;


 endmodule


module sync_rw #(parameter AWIDTH = 32) 
		(output reg [AWIDTH:0] wclk2_rptr,
                input	[AWIDTH:0] rptr,
		input	wclk, wrst); 

		reg [AWIDTH:0] wclk1_rptr;

always @(posedge wclk or negedge wrst) 
if (!wrst) 
{wclk2_rptr,wclk1_rptr} <= 0;

else	
{wclk2_rptr,wclk1_rptr} <= {wclk1_rptr,rptr};

 endmodule

module sync_wr #(parameter AWIDTH = 32) 
  (output reg [AWIDTH:0] rclk2_wptr,
   input	[AWIDTH:0] wptr,
		input	rclk, rrst); 

  reg [AWIDTH:0] rclk1_wptr;

always @(posedge rclk or negedge rrst) 

if (!rrst) 
{rclk2_wptr,rclk1_wptr} <= 0;

else	
{rclk2_wptr,rclk1_wptr} <= {rclk1_wptr,wptr};
 
endmodule

module rptr_empty #(parameter AWIDTH= 32) 
		   (output reg			rempty,
		    output 	[AWIDTH-1:0] 	raddr, 
            output reg  [AWIDTH:0] 	rptr, 
            input 	[AWIDTH:0]      rclk2_wptr,
		    input		        fiford, rclk, rrst);

  reg	[AWIDTH:0] rbin;
wire		     rempty_val;
  wire    [AWIDTH:0] rgraynext, rbinnext;

always @(posedge rclk or negedge rrst) 

if (!rrst) 
{rbin, rptr} <= 0;
else	
{rbin, rptr} <= {rbinnext, rgraynext};

assign raddr	= rbin[AWIDTH-1:0];

assign rbinnext	= rbin + (fiford & ~rempty); 
assign rgraynext = (rbinnext>>1) ^ rbinnext;

assign rempty_val = (rgraynext == rclk2_wptr);

always @(posedge rclk or negedge rrst)
 if (!rrst) 
rempty <= 1'b1;
else	
rempty <= rempty_val;
endmodule

module wptr_full #(parameter AWIDTH = 32) 
		  (output reg	wfull,
		   output	[AWIDTH-1:0] waddr, 
           output reg 	[AWIDTH:0] wptr,
           input	[AWIDTH:0] wclk2_rptr,
		   input	fifowr, wclk, wrst);

  reg	[AWIDTH:0] wbin;
wire		   wfull_val;
  wire 	[AWIDTH:0] wgraynext, wbinnext;


always @(posedge wclk or negedge wrst) 
if (!wrst) 
{wbin, wptr} <= 0;
else	
{wbin, wptr} <= {wbinnext, wgraynext};
  assign waddr = wbin[AWIDTH-1:0];

assign wbinnext	= wbin + (fifowr & ~wfull); 
assign wgraynext = (wbinnext>>1) ^ wbinnext;
assign wfull_val = (wgraynext=={~wclk2_rptr[AWIDTH:AWIDTH-1],wclk2_rptr[AWIDTH-2:0]});

always @(posedge wclk or negedge wrst)
 if (!wrst)
 wfull	<= 1'b0;
else	wfull	<= wfull_val; 
endmodule
 
