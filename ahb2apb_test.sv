// File name: 			AHB2APB_Test.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module test
// File history: 		0.1  - Dimitrije S. - Inital version.


`ifndef AHB2APB_TEST
`define AHB2APB_TEST
import env_pkg::*;

class ahb2apb_test extends uvm_test;
	
	ahb2apb_env   env;
	virtual_sequence v_seq;
	
	`uvm_component_utils(ahb2apb_test)
  
  	extern function new(string name = "ahb2apb_test", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function new(string name = "ahb2apb_test",uvm_component parent=null);
    super.new(name,parent);
endfunction 
 
function void ahb2apb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
		env = ahb2apb_env::type_id::create("env", this);
		vseq = virtual_sequence::type_id::create("vseq", this);

		uvm_config_db#(uvm_object_wrapper)::set(this, "env.vseq.run_phase", "default_sequence", virtual_sequence::type_id::get());
		
endfunction 

function void ahb2apb_test::run_phase(uvm_phase phase);
	super.build_phase(phase);
	
		phase.raise_objection(this);
		vseq.start(env.vseq);
		phase.drop_objection(this);
		
endfunction

`endif //AHB2APB_TEST_