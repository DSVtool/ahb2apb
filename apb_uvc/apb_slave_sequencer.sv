// File name: 			APB_slave_Sequencer.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module slave sequencer
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_SLAVE_SQR
`define APB_SLAVE_SQR

`define APB_IF vif.clk_cb				

class apb_slave_sqr #(parameter APB_BUS_W = 32, APB_ADDR_W = 32) extends uvm_sequencer #(apb_tr#(APB_BUS_W,APB_ADDR_W));

	virtual apb_vif #(APB_BUS_W,APB_ADDR_W) vif;

	`uvm_component_param_utils(apb_slave_sqr #(APB_BUS_W,APB_ADDR_W))

	extern function new(string name = "apb_slave_sqr", uvm_component parent = null);

	extern virtual function void build_phase(uvm_phase phase);	
	extern virtual task run_phase(uvm_phase phase);

endclass

function apb_slave_sqr::new(string name = "apb_slave_sqr", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void apb_slave_sqr::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual apb_vif #(APB_BUS_W,APB_ADDR_W))::get(this, "", "apb_vif", vif))
		begin
			`uvm_fatal("apb_slave_sqr - build_phase", "apb_vif not set!");
		end

endfunction

task apb_slave_sqr::run_phase(uvm_phase phase);		
	
	forever begin
		@(negedge vif.reset_n);

		if(m_find_sequence(-1) != null)
			begin
				stop_sequences();
			end
	end
endtask


`endif //APB_SLAVE_SQR
