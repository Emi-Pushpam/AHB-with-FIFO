class ahb_sequence extends uvm_sequence #(ahb_sequence_item);
  
  `uvm_object_utils(ahb_sequence)
  
  function new(string name="");
    super.new(name);
    
  endfunction

  
  task body();
    
    ahb_sequence_item trans = new("transaction");
    
    start_item(trans);
    
    
    finish_item(trans);
    
  endtask
  
endclass

