// File name: 			APB_Master_Sequencer.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module master sequencer
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_MASTER_SQR
`define APB_MASTER_SQR

`define APB_IF vif.clk_cb				

class apb_master_sqr #(parameter APB_DW = 32, APB_AW = 32) extends uvm_sequencer #(apb_tr);

	virtual apb_vif #(APB_DW,APB_AW) vif;

	`uvm_component_param_utils(apb_master_sqr #(APB_DW,APB_AW))

	extern function new(string name = "apb_master_sqr", uvm_component parent = null);

	extern virtual function void build_phase(uvm_phase phase);	
	extern virtual task run_phase(uvm_phase phase);

endclass

function apb_master_sqr::new(string name = "apb_master_sqr", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void apb_master_sqr::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual apb_vif #(APB_DW,APB_AW))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("apb_master_sqr - build_phase", "vif not set!");
		end

endfunction

task apb_master_sqr::run_phase(uvm_phase phase);		
	
	forever begin
		@(negedge vif.reset_n);

		if(m_find_sequence(-1) != null)
			begin
				stop_sequences();
			end
	end
endtask

`endif //APB_MASTER_SQR
