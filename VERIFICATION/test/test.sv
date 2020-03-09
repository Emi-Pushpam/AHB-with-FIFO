class ahb_test extends uvm_test;
  `uvm_component_utils(test)
  
  ahb_env env;
  ahb_sequence seq;
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ahb_env::type_id::create("env",this);
    seq = ahb_sequence::type_id::create("seq");
    
  endfunction
  
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
    
    seq.start(env.my_agent1.sequencer);
    
    phase.drop_objection(this);
    
  endtask
  
endclass
