// File name: 			APB_slave_Driver.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module slave driver
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_SLAVE_DRV
`define APB_SLAVE_DRV

`define APB_IF vif.mst_cb				

class apb_slave_drv #(parameter APB_BUS_W = 32, APB_ADDR_W = 32) extends uvm_driver #(apb_tr);

	rand bit [APB_BUS_W-1:0] read_data;
	rand int ready_delay;

	virtual apb_vif #(APB_BUS_W,APB_ADDR_W) vif;

	`uvm_component_param_utils(apb_slave_drv #(APB_BUS_W,APB_ADDR_W)) 

	extern function new(string name = "apb_slave_drv", uvm_component parent);
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function init();
	extern virtual task drive();

endclass

function apb_slave_drv::new(string name = "apb_slave_drv", uvm_component parent);
	super.new(name, parent);
endfunction

function void apb_slave_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual apb_vif #(APB_BUS_W,APB_ADDR_W))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("apb_slave_drv - build_phase", "vif not set!");
		end
		
endfunction

function void apb_slave_drv::connect_phase(uvm_phase phase);
	super.build_phase(phase);		
endfunction

task apb_slave_drv::run_phase(uvm_phase phase);
	super.run_phase(phase);

	@(posedge vif.clk);
	init();	

	forever begin
		@(`APB_IF);
			fork
				begin
					drive();
				end
				
				begin
					@(negedge vif.reset_n);
					init();
				end
			join_any
			disable fork;
		end
endtask

function apb_slave_drv::init();
	
	`APB_IF.pready <= 1'b0;
	`APB_IF.prdata <= 31'b0;
	
endfunction

task apb_slave_drv::drive();
	
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
					std::randomize (ready_delay);	
					if(`APB_IF.pwrite) 															//write transfer
						begin
							#(ready_delay*1ns);
							@(posedge vif.clk);
							`APB_IF.pready <= 0;		
						end
					else	
						begin	
							std::randomize(readable_data);
							`APB_IF.prdata <= readable_data;									//read transfer
							#(ready_delay*1ns);											    
							@(posedge vif.clk);
							`APB_IF.pready <= 0;	
						end	
				end			
		end
endtask


`endif //APB_SLAVE_DRV