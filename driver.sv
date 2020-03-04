import uvm_pkg::*;
`include "uvm_macros.svh"

class ahb_driver extends uvm_driver #(ahb_sequence_item);

`uvm_component_utils(ahb_driver)


virtual ahb_intf intf_vir;


function new(string name, uvm_component parent);
super.new(name,parent);
endfunction:new

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(virtual ahb_intf)::get(this,"","intf_vir",intf_vir))
begin
`uvm_error("build_phase","config_db-Unable to get intf_vir");
end
endfunction:build_phase

task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(ahb_tran);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase

  
   task drive();
    intf_vir.HWRITE <= 0;
        @(posedge intf_vir.DRIVER.clk);
    
    intf_vir.HADDR <= ahb_tran.HADDR;
    
    if(HWRITE==1) begin // write operation
      intf_vir.HWRITE <= ahb_tran.HWRITE;
      intf_vir.HWDATA <= ahb_tran.HWDATA;
      @(posedge intf_vir.DRIVER.clk);
    end
    else if(HWRITE==0) begin //read operation
      intf_vir.HWRITE <= ahb_tran.HRDATA;
          @(posedge intf_vir.DRIVER.clk);
       req.HRDATA = intf_vir.HRDATA;
    end
    
  endtask : drive
endclass : ahb_driver