// File name: 			APB_Master_Agent.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module master agent
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_MASTER_AGENT
`define APB_MASTER_AGENT

class apb_master_agent #(parameter APB_DW = 32, APB_AW = 32) extends uvm_agent;

	`uvm_component_param_utils(apb_master_agent #(APB_DW,APB_AW))

	apb_master_drv #(APB_DW,APB_AW) 		drv;
	apb_master_sqr #(APB_DW,APB_AW) 		sqr;
	apb_monitor    #(APB_DW,APB_AW)			mon;

	extern function new(string name = "apb_master_agent", uvm_component parent = null);

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void run_phase(uvm_phase phase);

endclass

function apb_master_agent::new(string name = "apb_master_agent", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void apb_master_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);

	`uvm_info("apb_master_agent - build_phase", $psprintf("active passive enum val %s", is_active.name()), UVM_NONE);

	if(get_is_active() == UVM_ACTIVE)
		begin
			drv = apb_master_drv #(APB_DW,APB_AW) ::type_id::create("drv", this);
			sqr = apb_master_sqr #(APB_DW,APB_AW) ::type_id::create("sqr", this);			
		end

	mon = apb_monitor #(APB_DW,APB_AW)::type_id::create("mon", this);

endfunction

function void apb_master_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	if(get_is_active() == UVM_ACTIVE)
		begin
			drv.seq_item_port.connect(sqr.seq_item_export);
		end

endfunction

function void apb_master_agent::run_phase(uvm_phase phase);
	super.run_phase(phase);
endfunction

`endif //APB_MASTER_AGENT
