// File name: 			APB_slave_Agent.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module slave agent
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_SLAVE_AGENT
`define APB_SLAVE_AGENT

class apb_slave_agent #(parameter APB_BUS_W = 32, APB_ADDR_W = 32) extends uvm_agent;

	`uvm_component_param_utils(apb_slave_agent #(APB_BUS_W,APB_ADDR_W))

	apb_slave_drv #(APB_BUS_W,APB_ADDR_W) 		drv;
	apb_slave_sqr #(APB_BUS_W,APB_ADDR_W) 		sqr;
	apb_monitor    #(APB_BUS_W,APB_ADDR_W)		mon;

	extern function new(string name = "apb_slave_agent", uvm_component parent = null);

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function apb_slave_agent::new(string name = "apb_slave_agent", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void apb_slave_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
		begin
			`uvm_fatal("apb_slave_agent - build_phase", "uvm_active_passive not set");
		end

	`uvm_info("apb_slave_agent - build_phase", $psprintf("active passive enum val %s", is_active.name()), UVM_NONE);

	if(get_is_active() == UVM_ACTIVE)
		begin
			drv = apb_slave_drv #(APB_BUS_W,APB_ADDR_W) ::type_id::create("drv", this);
			sqr = apb_slave_sqr #(APB_BUS_W,APB_ADDR_W) ::type_id::create("sqr", this);			
		end

	mon = apb_monitor #(APB_BUS_W,APB_ADDR_W)::type_id::create("mon", this);

endfunction

function void apb_slave_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	if(get_is_active() == UVM_ACTIVE)
		begin
			drv.seq_item_port.connect(sqr.seq_item_export);
		end
	`uvm_info("apb_slave_agent - connect_phase", $psprintf("Succesfully completed"), UVM_NONE);
endfunction

task apb_slave_agent::run_phase(uvm_phase phase);
	super.run_phase(phase);
endtask


`endif //APB_SLAVE_AGENT

