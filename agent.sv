

import uvm_pkg::*;
`include "uvm_macros.svh"


`include "ahb_sequence_item.sv"
`include "ahb_sequencer.sv"
`include "ahb_sequence.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"


class ahb_agent extends uvm_agent;

  
  ahb_driver    driver;
  ahb_sequencer sequencer;
  ahb_monitor   monitor;

  `uvm_component_utils(ahb_agent)
  
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = ahb_monitor::type_id::create("monitor", this);
      driver    = ahb_driver::type_id::create("driver", this);
      sequencer = ahb_sequencer::type_id::create("sequencer", this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    
      driver.seq_item_port.connect(sequencer.seq_item_export);
   
  endfunction : connect_phase

endclass : ahb_agent
