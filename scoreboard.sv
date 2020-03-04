import uvm_pkg::*;
`include "uvm_macros.svh"



class my_scoreboard extends uvm_component;

`uvm_component_utils(my_scoreboard)

uvm_analysis_export #(my_transaction) aport;

function new(string name, uvm_component parent);
super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
super.build_phase(phase);
aport=new("aport,this");
endfunction:build_phase

function void connect_phase (uvm_phase phase);
super.connect_phase(phase);
endfunction:connect_phase

task run_phase(uvm_phase phase);
endtask:run_phase

endclass:my_scoreboard




class ahb_scoreboard extends ahb_scoreboard;
  
  
  ahb_seq_item pkt_qu[$];
  
  
  bit [7:0] sc_ahb [4];

  uvm_analysis_port#(ahb_seq_item, ahb_scoreboard) a_port;
  `uvm_component_utils(ahb_scoreboard)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      a_port = new("a_port", this);
      foreach(sc_ahb[i]) sc_ahb[i] = 8'hFF;
  endfunction: build_phase
  
  
   function void write(ahb_seq_item ahb_pkt);
    //pkt.print();
    pkt_qu.push_back(ahb_pkt);
  endfunction : write

   task run_phase(uvm_phase phase);
    ahb_seq_item ahb_pkt;
    
    forever begin
      wait(pkt_qu.size() > 0);
      ahb_pkt = pkt_qu.pop_front();
      
      if(ahb_pkt.HWRITE==1) begin
        sc_ahb[ahb_pkt.HADDR] = ahb_pkt.HWDATA;
        `uvm_info(get_type_name(),$sformatf("------ :: WRITE DATA       :: ------"),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_pkt.HADDR),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Data: %0h",ahb_pkt.HWDATA),UVM_LOW)
        `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)        
      end
      else if(ahb_pkt.HWRITE==0) begin
        if(sc_ahb[ahb_pkt.HADDR] == ahb_pkt.HRDATA) begin
          `uvm_info(get_type_name(),$sformatf("------ :: READ DATA  :: ------"),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_pkt.HADDR),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",sc_ahb[ahb_pkt.HADDR],ahb_pkt.HRDATA),UVM_LOW)
          `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
        end
        else begin
          `uvm_error(get_type_name(),"------ :: READ DATA MisMatch :: ------")
          `uvm_info(get_type_name(),$sformatf("Addr: %0h",ahb_pkt.HADDR),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",sc_ahb[ahb_pkt.HADDR],ahb_pkt.HRDATA),UVM_LOW)
          `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
        end
      end
    end
  endtask : run_phase
endclass : ahb_scoreboard

