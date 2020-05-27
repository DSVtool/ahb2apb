// File name: 			AHB2APB_Virtual_Sequencer.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module virtual sequencer
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_VR_SQCR
`define AHB2APB_VR_SQCR

class virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);

	`uvm_component_utils(virtual_sequencer)

	ahb_master_sqr #(`AHB_BUS_W,`AHB_ADDR_W)	ahb_sqr;
	apb_slave_sqr #(`APB_BUS_W,`APB_ADDR_W) 	apb_sqr;
	extern function new(string name = "virtual_sequencer", uvm_component parent);

endclass

function virtual_sequencer::new(string name = "virtual_sequencer", uvm_component parent);		
	super.new(name, parent);
endfunction


`endif //AHB2APB_VR_SQCR