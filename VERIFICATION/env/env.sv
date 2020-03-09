

class ahb_env extends uvm_env;
  

  ahb_agent      agent;
  ahb_scoreboard ahb_scb;
  
  `uvm_component_utils(ahb_env)
  

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = ahb_agent::type_id::create("ahb_agnt", this);
    ahb_scb  = ahb_scoreboard::type_id::create("ahb_scb", this);
  endfunction : build_phase
  
  
  function void connect_phase(uvm_phase phase);
    agent.monitor.a_port.connect(ahb_scb.a_port_export);
  endfunction : connect_phase

task run_phase(uvm_phase phase);
endtask

endclass



