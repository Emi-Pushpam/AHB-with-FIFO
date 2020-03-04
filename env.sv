class ahb_env extends uvm_env;
`uvm_component_utils(ahb_env)
ahb_agent my_agent1;
ahb_scoreboard ahb_scoreboard1;

function new(string name, uvm_component parent);
super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_agent1=my_agent::type_id::create("my_agent1",this);
ahb_scoreboard1=ahb_scoreboard::type_id::create("ahb_scoreboard1",this);
endfunction:build_phase

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
my_agent1.aport.connect(my_scoreboard1.aport);
endfunction:connect_phase

task run_phase(uvm_phase phase);
endtask:run_phase 

endclass:my_env



`include "ahb_agent.sv"
`include "ahb_scoreboard.sv"

class ahb_model_env extends uvm_env;
  

  ahb_agent      ahb_agnt;
  ahb_scoreboard ahb_scb;
  
  `uvm_component_utils(ahb_model_env)
  

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    ahb_agnt = ahb_agent::type_id::create("ahb_agnt", this);
    ahb_scb  = ahb_scoreboard::type_id::create("ahb_scb", this);
  endfunction : build_phase
  
  
  function void connect_phase(uvm_phase phase);
    ahb_agnt.monitor.a_port.connect(ahb_scb.a_port_export);
  endfunction : connect_phase

endclass : ahb_model_env



