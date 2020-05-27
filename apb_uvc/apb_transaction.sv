// File name: 			APB_Master_Agent.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module master agent
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_TR
`define APB_TR

class apb_tr #(parameter APB_DW = 32, APB_AW = 32) extends uvm_sequence_item;

	 	 bit [APB_AW-1:0] paddr;
		 bit [APB_DW-1:0] pwdata;
	rand bit [APB_DW-1:0] prdata;	
    	 bit 			  penable;
     	 bit 			  pwrite;				
    //rand bit 			  pstrobe;
    rand bit			  psel;
	rand bit 			  pready;
	rand int 			  ready_delay;											// Delay after which pready appears (simulating wait states)	

	`uvm_object_param_utils_begin(apb_tr)
		`uvm_field_int(paddr, 		 UVM_ALL_ON)
		`uvm_field_int(pwdata,  	 UVM_ALL_ON)
		`uvm_field_int(prdata,   	 UVM_ALL_ON)
		`uvm_field_int(penable,		 UVM_ALL_ON)
		//`uvm_field_int(pstrobe,		 UVM_ALL_ON)
		`uvm_field_int(pwrite,  	 UVM_ALL_ON)
		`uvm_field_int(pready,  	 UVM_ALL_ON)	
		`uvm_field_int(psel,    	 UVM_ALL_ON)	
		`uvm_field_int(ready_delay,  UVM_ALL_ON)				
	`uvm_object_utils_end
    
    constraint general_c {	
		
		ready_delay inside {[0:10]};
    
	}

	extern function new(string name = "apb_tr");

endclass

function apb_tr::new(string name = "apb_tr");
	super.new(name);
endfunction

`endif //APB_TR
