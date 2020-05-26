// File name: 			APB_Master_Driver.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module master driver
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_MASTER_DRV
`define APB_MASTER_DRV

`define APB_IF vif.clk_cb				

class apb_master_drv #(parameter APB_DW = 32, APB_AW = 32) extends uvm_driver #(apb_tr);

	virtual apb_vif #(APB_DW,APB_AW) vif;

	`uvm_component_param_utils(apb_master_drv #(APB_DW,APB_AW)) 

	extern function new(string name = "apb_master_drv", uvm_component parent);
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function init();
	extern virtual task drive();

endclass

function apb_master_drv::new(string name = "apb_master_drv", uvm_component parent);
	super.new(name, parent);
endfunction

function void apb_master_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual apb_vif #(APB_DW,APB_AW))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("apb_master_drv - build_phase", "vif not set!");
		end
		
endfunction

function void apb_master_drv::connect_phase(uvm_phase phase);
	super.build_phase(phase);		
endfunction

task apb_master_drv::run_phase(uvm_phase phase);
	super.run_phase(phase);

	@(posedge vif.clk);
	init();	

	forever begin
		@(`APB_IF);

		fork
			begin
				fork
					begin
						seq_item_port.get_next_item(req);
						drive();
						seq_item_port.item_done();
					end
					
					begin
						@(negedge vif.reset_n);
						init();
					end
				join_any
				disable fork;
			end
		join
	end
endtask

function apb_master_drv::init();
	
	`APB_IF.pready = 1'b0;
	`APB_IF.prdata = 31'b0;
	
endfunction

task apb_master_drv::drive();
	
	bit enable_flag;

	@(`APB_IF)
	 
	@(posedge vif.clk);
		begin
			if(`APB_IF.psel)
				begin
					while (!enable_flag)													//Wait for ready signal
						begin
							@(posedge vif.clk);												//Sta ako su spremni pre prve clk ivice?
							if(`APB_IF.penable)
								enable_flag = 1;
						end
				if(`APB_IF.pwrite) 															//write transfer
					begin
						#(`APB_IF.ready_delay*1ns);
						@(posedge vif.clk);
						`APB_IF.pready = 0;		
					end
				else	
					begin		
						`APB_IF.prdata = req.prdata;
						#(`APB_IF.ready_delay*1ns);											//read transfer
						@(posedge vif.clk);
						`APB_IF.pready = 0;	
					end	
				end	
			else
				begin
					break;	
				end			
		end
endtask

`endif //APB_MASTER_DRV