// File name: 			apb_transaction.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module transaction
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_TR
`define APB_TR

class apb_tr #(parameter APB_BUS_W = 32, APB_ADDR_W = 32) extends uvm_sequence_item;

	 	 bit [APB_ADDR_W-1:0] paddr;
		 bit [APB_BUS_W-1:0]  pwdata;
	rand bit [APB_BUS_W-1:0]  prdata;	
    	 bit 				  penable;
     	 bit 			  	  pwrite;				
  //rand bit 			 	  pstrobe;
    rand bit			 	  psel;
	rand bit 			  	  pready;

	`uvm_object_param_utils_begin(apb_tr #(APB_BUS_W,APB_ADDR_W))
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
    
	extern function new(string name = "apb_tr");

endclass

function apb_tr::new(string name = "apb_tr");
	super.new(name);
endfunction


`endif //APB_TR
