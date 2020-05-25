// File name: 			AHB_Master_Sequencer.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module master sequencer
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_MASTER_SQR
`define AHB_MASTER_SQR

`define AHB_IF vif.clk_cb				

class ahb_master_sqr #(parameter AHB_DW = 32, AHB_AW = 32) extends uvm_sequencer #(ahb_tr #(AHB_DW,AHB_AW));

	virtual ahb_vif #(AHB_DW,AHB_AW) vif;

	`uvm_component_param_utils(ahb_master_sqr #(AHB_DW,AHB_AW))

	extern function new(string name = "ahb_master_sqr", uvm_component parent = null);

	extern virtual function void build_phase(uvm_phase phase);	
	extern virtual task run_phase(uvm_phase phase);

endclass

function ahb_master_sqr::new(string name = "ahb_master_sqr", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void ahb_master_sqr::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual ahb_vif #(AHB_DW,AHB_AW))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("ahb_master_sqr - build_phase", "vif not set!");
		end

endfunction

task ahb_master_sqr::run_phase(uvm_phase phase);		
	
	forever begin
		@(negedge vif.reset_n);

		if(m_find_sequence(-1) != null)
			begin
				stop_sequences();
			end
	end
endtask

`endif //AHB_MASTER_SQR
