// File name: 			AHB2APB_Test.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module test
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_TEST
`define AHB2APB_TEST

class ahb2apb_test extends uvm_test;
	
	ahb2apb_env   env;
	
	`uvm_component_utils(ahb2apb_test)
  
  	extern function new(string name = "ahb2apb_test", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task void run_phase(uvm_phase phase);

endclass

function ahb2apb_test::new(string name = "ahb2apb_test",uvm_component parent=null);
    super.new(name,parent);
endfunction 
 
function void ahb2apb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
		env = ahb2apb_env::type_id::create("env", this);
		
endfunction 

task ahb2apb_test::run();
		uvm_config_db#(uvm_object_wrapper)::set(this, "env.vseqr.run_phase", "default_sequence", virtual_sequence::type_id::get());
endtask


`endif //AHB2APB_TEST_