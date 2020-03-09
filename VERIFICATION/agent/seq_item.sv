class ahb_sequence_item extends uvm_sequence_item;

	rand logic	hclk;
	rand logic   hreset; 
	rand logic   hsel;
	rand logic	[19:0]	haddr; 
	rand logic	[2:0]	hburst; 
	rand logic	[1:0]	htrans; 
	rand logic	[31:0]	hwdata; 
	rand logic	hwrite; 
	rand logic	wrst;
	rand logic	rrst;
	rand logic	wdata;
	
  
  function new(string name);
    super.new(name);
  endfunction;

endclass
