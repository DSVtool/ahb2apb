// File name: 			AHB2APB_Test.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module test
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_TEST
`define AHB2APB_TEST

class ahb2apb_test extends uvm_test;
	
	ahb2apb_env   env;
	virtual_sequence v_seq;

	`uvm_component_utils(ahb2apb_test)
  
  	extern function new(string name = "ahb2apb_test", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function ahb2apb_test::new(string name = "ahb2apb_test",uvm_component parent=null);
    super.new(name,parent);
endfunction 
 
function void ahb2apb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
		env = ahb2apb_env::type_id::create("env", this);
		v_seq = virtual_sequence::type_id::create("v_seq", this);

endfunction 

task ahb2apb_test::run_phase(uvm_phase phase);
		//uvm_config_db#(uvm_object_wrapper)::set(this, "env.vseqr.run_phase", "default_sequence", virtual_sequence::type_id::get());

		phase.raise_objection(this);
		v_seq.start(env.vseqr);
		phase.drop_objection(this);
endtask


`endif //AHB2APB_TEST_