`include "uvm_macros.svh"

import uvm_pkg::*;
import agent_pkg::*;

`include "interface.sv"

module test_bench;
  
  reg clk = 0;
  
  inf in(clk);
  
  initial begin
    uvm_config_db #(virtual inf)::set(null,"*","inf",in);
    
  end
  
  initial begin
    
    run_test("test");
    
  end
  
  always #10 clk=~clk;
  
  
endmodule
