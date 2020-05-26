// File name: 			APB_Monitor.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module transaction
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_MONITOR
`define APB_MONITOR

`define APB_MON_IF vif.mon_cb

class apb_monitor #(parameter APB_DW = 32, APB_AW = 32) extends uvm_monitor;

	virtual apb_vif #(APB_DW,APB_AW) vif;

	uvm_analysis_port #(apb_tr #(APB_DW,APB_AW)) default_ap;

	`uvm_component_param_utils(apb_monitor #(APB_DW,APB_AW))

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

	if(!uvm_config_db#(virtual apb_vif #(APB_DW,APB_AW))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("apb_monitor - build_phase", "vif not set!");
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
				fork
					main_task();
					begin
						@(negedge vif.reset_n);
					end
				join_any
				disable fork;
			end
		join
	end
endtask

task apb_monitor::main_task();			
	
	apb_tr #(APB_DW,APB_AW) trans;
	
	`uvm_info("apb_monitor", "monitor main started", UVM_LOW);

	forever begin
		if(`APB_MON_IF.pready && `APB_MON_IF.penable)
			@(posedge clk);
				begin
					trans = ahb_tr #(APB_DW,APB_AW)::type_id::create("trans");
					
					trans.pwdata   = `APB_MON_IF.pwdata;
					trans.prdata   = `APB_MON_IF.prdata;
					trans.paddr    = `APB_MON_IF.paddr;
					trans.pwrite   = `APB_MON_IF.pwrite;
					trans.pstrobe  = `APB_MON_IF.pstrobe;
					trans.penable  = `APB_MON_IF.penable;
					trans.pready   = `APB_MON_IF.pready;
						
					default_ap.write(trans);			
				end			
	end	
endtask

`endif //APB_MONITOR
