// File name: 			AHB_Master_Agent.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module master agent
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_MASTER_AGENT
`define AHB_MASTER_AGENT

class ahb_master_agent #(parameter AHB_DW = 32, AHB_AW = 32) extends uvm_agent;

	`uvm_component_param_utils(ahb_master_agent #(AHB_DW,AHB_AW))

	ahb_master_drv #(AHB_DW,AHB_AW)  		drv;
	ahb_master_sqr #(AHB_DW,AHB_AW)  		sqr;
	ahb_monitor    #(AHB_DW,AHB_AW)			mon;
	ahb_cfg        #(AHB_DW,AHB_AW)	     	cfg;

	extern function new(string name = "ahb_master_agent", uvm_component parent = null);

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void run_phase(uvm_phase phase);

endclass

function ahb_master_agent::new(string name = "ahb_master_agent", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void ahb_master_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);

	if(!uvm_config_db#(ahb_cfg #(AHB_DW,AHB_AW))::get(this, "", "cfg", cfg))
		begin
			`uvm_fatal("ahb_master_agent - build_phase", "cfg not set!");
		end

	`uvm_info("ahb_master_agent - build_phase", $psprintf("active passive enum val %s", is_active.name()), UVM_NONE);

	if(get_is_active() == UVM_ACTIVE)
		begin
			drv = ahb_master_drv #(AHB_DW,AHB_AW) ::type_id::create("drv", this);
			sqr = ahb_master_sqr #(AHB_DW,AHB_AW) ::type_id::create("sqr", this);			
		end

	mon = ahb_monitor #(AHB_DW,AHB_AW) ::type_id::create("mon", this);

endfunction

function void ahb_master_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	if(get_is_active() == UVM_ACTIVE)
		begin
			drv.seq_item_port.connect(sqr.seq_item_export);
		end

endfunction

`endif //AHB_MASTER_AGENT
