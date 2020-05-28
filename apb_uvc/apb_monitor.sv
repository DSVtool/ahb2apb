// File name: 			APB_Monitor.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module transaction
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_MONITOR
`define APB_MONITOR

`define APB_MON_IF vif.mon_cb

class apb_monitor #(parameter APB_BUS_W = 32, APB_ADDR_W = 32) extends uvm_monitor;

	virtual apb_vif #(APB_BUS_W,APB_ADDR_W) vif;

	uvm_analysis_port #(apb_tr #(APB_BUS_W,APB_ADDR_W)) default_ap;

	`uvm_component_param_utils(apb_monitor #(APB_BUS_W,APB_ADDR_W))

	extern function new(string name = "apb_monitor", uvm_component parent);

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

	extern virtual task main_task();

endclass

function apb_monitor::new(string name = "apb_monitor", uvm_component parent);
	super.new(name, parent);
endfunction

function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);

	default_ap = new("default_ap", this);

	if(!uvm_config_db#(virtual apb_vif #(APB_BUS_W,APB_ADDR_W))::get(this, "", "apb_vif", vif))
		begin
			`uvm_fatal("apb_monitor - build_phase", "apb_vif not set!");
		end

endfunction

function void apb_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction

task apb_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);

	@(posedge vif.reset_n);

	forever begin
		@(`APB_MON_IF);
		fork
			begin
				main_task();
			end
				
			begin
				@(negedge vif.reset_n);
			end
			join_any
		disable fork;
	end
endtask

task apb_monitor::main_task();			
	
	apb_tr #(APB_BUS_W,APB_ADDR_W) trans;
	
	`uvm_info("apb_monitor", "APB monitor main task started", UVM_LOW);

	forever begin
		if(`APB_MON_IF.pready && `APB_MON_IF.penable)
			@(posedge vif.clk);
				begin
					trans = apb_tr #(APB_BUS_W,APB_ADDR_W)::type_id::create("trans");
					
					trans.pwdata   = `APB_MON_IF.pwdata;
					trans.prdata   = `APB_MON_IF.prdata;
					trans.paddr    = `APB_MON_IF.paddr;
					trans.pwrite   = `APB_MON_IF.pwrite;
					//trans.pstrobe  = `APB_MON_IF.pstrobe;
					trans.penable  = `APB_MON_IF.penable;
					trans.pready   = `APB_MON_IF.pready;
						
					default_ap.write(trans);			
				end			
	end	
endtask


`endif //APB_MONITOR
