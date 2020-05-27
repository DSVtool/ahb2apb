// File name: 			AHB_Monitor.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module monitor
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_MONITOR
`define AHB_MONITOR

`define AHB_MON_IF vif.mon_cb

class ahb_monitor #(parameter AHB_DW = 32, AHB_AW = 32) extends uvm_monitor;

	virtual ahb_vif #(AHB_DW,AHB_AW) vif;

	uvm_analysis_port #(ahb_tr #(AHB_DW,AHB_AW)) default_ap;
 
	`uvm_component_param_utils(ahb_monitor #(AHB_DW,AHB_AW))

	extern function new(string name = "ahb_monitor", uvm_component parent);

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

	extern virtual task main_task();

endclass

function ahb_monitor::new(string name = "ahb_monitor", uvm_component parent);
	super.new(name, parent);
endfunction

function void ahb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);

	default_ap = new("default_ap", this);

	if(!uvm_config_db#(virtual ahb_vif #(AHB_DW,AHB_AW))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("ahb_monitor - build_phase", "vif not set!");
		end

endfunction

function void ahb_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction

task ahb_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);

	@(posedge vif.reset_n);

	forever begin
		@(`AHB_MON_IF);
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

task ahb_monitor::main_task();			
	
	ahb_tr #(AHB_DW,AHB_AW) trans;
	int i = 0;
	int trans_prev,trans_curr;
	int trans_flag = 0, trans_flag2 = 1;
	
	`uvm_info("ahb_monitor", "monitor main started", UVM_LOW);

	forever begin
		@(`AHB_MON_IF);
		begin	
			while(trans_flag2 !== 2)
				if(`AHB_MON_IF.hready == 1)
					begin
						@(posedge vif.clk) 	
							
							trans = ahb_tr #(AHB_DW,AHB_AW)::type_id::create("trans");

							trans_flag2	   = trans_flag + 1;   																					

							trans.hwdata   = `AHB_MON_IF.hwdata;
							trans.hrdata   = `AHB_MON_IF.hrdata;
							trans.haddr    = `AHB_MON_IF.haddr;
							trans.hwrite   = `AHB_MON_IF.hwrite;
							trans.hburst   = `AHB_MON_IF.hburst;
							trans.hsize	   = `AHB_MON_IF.hsize;
							trans.htrans   = `AHB_MON_IF.htrans;
							
							trans_prev     = trans_curr;
							trans_curr	   = `AHB_MON_IF.htrans;

							i++;

							if(trans_prev == 3 && (trans_curr == 0 || trans_curr == 2))
								trans_flag = 1;

							default_ap.write(trans);													// writing to the analysis port
					end	
		end				
	end	
endtask

`endif //AHB_MONITOR
