// File name: 			AHB2APB_Enviroment.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module enviroment
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_ENVIROMENT
`define AHB2APB_ENVIROMENT

class ahb2apb_env extends uvm_env;

	ahb_master_agent	#(`AHB_BUS_W,`AHB_ADDR_W) 	  	ahb_agnt;
	apb_master_agent 	#(`APB_BUS_W,`APB_ADDR_W) 	  	apb_agnt;
	ahb2apb_scoreboard  				  				scrboard;
	virtual_sequencer 					  				vseq;
	
	`uvm_component_utils(ahb2apb_env)  

	extern function new(string name = "ahb2apb_env", uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
endclass 

function ahb2apb_env::new(string name = "ahb2apb_env", uvm_component parent);		
	super.new(name, parent);
endfunction

function void ahb2apb_env::build_phase(uvm_phase phase);
	super.build_phase(phase);

		ahb_agnt = ahb_master_agent#(`AHB_BUS_W,`AHB_ADDR_W)::type_id::create("ahb_agnt", this);
		apb_agnt = apb_master_agent#(`APB_BUS_W,`APB_ADDR_W)::type_id::create("apb_agnt", this);

		/* setting both agents to be active */
		uvm_config_db#(uvm_active_passive_enum)::set(this, ".ahb_agent", "is_active", UVM_ACTIVE);
		uvm_config_db#(uvm_active_passive_enum)::set(this, ".apb_agent", "is_active", UVM_ACTIVE);
		
		vseq = virtual_sequencer::type_id::create("vseq", this);
		scrboard = ahb2apb_scoreboard::type_id::create("scrboard", this);

		/* setting the current bridge model parameters */
		uvm_config_db#(int)::set(this, ".ahb_agent.*", "buswidth", 32);    						// Data ahb write bus width set at 32b
		uvm_config_db#(int)::set(this, ".*", "apbwidth", 32);    								// Data ahb write bus width set at 32b

endfunction 

function void ahb2apb_env::connect_phase(uvm_phase phase);	
	super.connect_phase(phase);
		vseq.ahb_sqr.connect(ahb_agnt.sqr); 	
		vseq.apb_sqr.connect(apb_agnt.sqr);

		ahb_agnt.mon.default_ap.connect(scrboard.my_import);
		apb_agnt.mon.default_ap.connect(scrboard.my_import);

endfunction

`endif //AHB2APB_ENVIROMENT