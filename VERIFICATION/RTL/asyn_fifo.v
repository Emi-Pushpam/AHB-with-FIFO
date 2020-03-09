module asyn_fifo #(parameter DWIDTH = 32,
	       parameter AWIDTH = 18,
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
		.wclk(wclk), .rclken(fiford));

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
		 parameter AWIDTH = 5,
		 parameter DEPTH=1<<AWIDTH)   
		(output  reg	[DWIDTH-1:0] rdata, 
		input		[DWIDTH-1:0] wdata,
		input		[AWIDTH-1:0] waddr, raddr,
		input		wclken, rclken,wfull, wclk);


  	reg [DWIDTH-1:0]mem[0:DEPTH-1];

// Initializing Memory and Writing into it

  always @(posedge wclk)
begin
 if(wclken && (!wfull))
   begin
    mem[waddr]<= wdata;
     $display("%g wdata:%h",$time,wdata);
end 
end
  
  if(rclken && (!rempty)) begin

// Reading from Memory

assign rdata=mem[raddr];
  end
  
    
endmodule


module sync_rw #(parameter AWIDTH = 5) 
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

module sync_wr #(parameter AWIDTH = 5) 
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

module rptr_empty #(parameter AWIDTH= 5) 
		   (output reg			rempty,
		    output 	[AWIDTH-1:0] 	raddr, 
		    output reg  [AWIDTH:0] 	rptr, 
            input 	[AWIDTH:0]    rclk2_wptr,
		    input			fiford, rclk, rrst);

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

module wptr_full #(parameter AWIDTH = 5) 
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
 
