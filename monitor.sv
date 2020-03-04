import uvm_pkg::*;
`include "uvm_macros.svh"
class ahb_monitor extends uvm_monitor;

  virtual ahb_intf intf_vir;
  ahb_sequence_item collected;
  
  uvm_analysis_port #(ahb_sequence_item) a_port;
  
  `uvm_component_utils(ahb_monitor)

  
  function new (string name, uvm_component parent);
    super.new(name, parent);
    a_port = new("a_port", this);
  endfunction : new

  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_intf)::get(this, "", "intf_vir", intf_vir))
       `uvm_error("build_phase","config_db-Unable to get intf_vir");
  endfunction: build_phase
  
  
   task run_phase(uvm_phase phase);
    forever begin
      @(posedge intf_vir.MONITOR.clk);
      wait(intf_vir.monitor_cb.HWRITE || intf_vir.monitor_cb.HRDATA);
        collected.HADDR= .monitor_cb.HADDR;
      if(intf_vir.monitor_cb.HWRITE==1) begin
        collected.HWRITE = intf_vir.monitor_cb.HWRITE;
        collected.HWDATA = intf_vir.monitor_cb.HWDATA;
        collected.HWRITE = 0;
        @(posedge intf_vir.MONITOR.clk);
      end
      if(intf_vir.monitor_HWRITE==0) begin
        collected.HRDATA = intf_vir.monitor_cb.HRDATA;
        collected.HWRITE = 0;
        @(posedge intf_vir.MONITOR.clk);
        @(posedge intf_vir.MONITOR.clk);
        collected.HRDATA = intf_vir.monitor_cb.HRDATA;
      end
	  a_port.write(collected);
      end 
  endtask : run_phase

endclass : ahb_monitor
