// File name: 			APB_Master_Agent.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module master agent
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_TR
`define AHB_TR

class ahb_tr #(parameter AHB_BUS_W = 32, AHB_ADDR_W = 32) extends uvm_sequence_item;

    int max_length = 50;  					// max "undefined length" for allocating a dynamic array

	rand bit [AHB_ADDR_W-1:0] haddr;			// All transfers in a burst must be aligned to the address boundary equal to the size of the transfer. Page34
		 bit [AHB_BUS_W-1:0] hrdata;	
    rand bit [2:0]  hburst;
    rand bit [2:0]  hsize; 					// The transfer size set by HSIZE must be less than or equal to the width of the data bus.			
    rand bit [1:0]  htrans;  				// 00-IDLE / 01-BUSY / 10-NONSEQUENTAL / 11-SEQUENTAL
	rand bit 		hwrite;
   		 bit 		hready;
   		 bit 		hsel;
	rand int 		tr_delay;
	rand int 		blenght;
	rand int		undefburst_lenght;
	
	rand bit [AHB_BUS_W-1:0] hwdata [];   
	
	`uvm_object_param_utils_begin(ahb_tr #(AHB_BUS_W,AHB_ADDR_W))
		`uvm_field_int (haddr, 			   UVM_ALL_ON)
		`uvm_field_int (hrdata, 		   UVM_ALL_ON)
		`uvm_field_int (hburst, 		   UVM_ALL_ON)
		`uvm_field_int (hsize, 			   UVM_ALL_ON)
		`uvm_field_int (hwrite,   		   UVM_ALL_ON)
		`uvm_field_int (hready, 		   UVM_ALL_ON)
		`uvm_field_int (hsel,    		   UVM_ALL_ON)
		`uvm_field_int (undefburst_lenght, UVM_ALL_ON)
		`uvm_field_int (htrans,			   UVM_ALL_ON)		
		`uvm_field_int (blenght,  		   UVM_ALL_ON)
		`uvm_field_int (tr_delay,		   UVM_ALL_ON)		
		`uvm_field_array_int (hwdata, 	   UVM_ALL_ON)
	`uvm_object_utils_end
	    
    constraint general_c {	
    	hsize < $clog2(AHB_BUS_W)-2;
		tr_delay inside {[0:60]};
		soft hsel == 1;
	}
	
	constraint undefburst_c {	
		undefburst_lenght  inside {[1:max_length]};
		if( hburst !== 1)
			undefburst_lenght == 0;
	}
	
	constraint blenght_c{
		hburst == 3'b000 -> blenght == 1; 
		hburst == 3'b001 -> blenght == undefburst_lenght;		 		// "undefined" length INC burst
		hburst == 3'b010 -> blenght == 4;		
		hburst == 3'b011 -> blenght == 4;		
		hburst == 3'b100 -> blenght == 8;		
		hburst == 3'b101 -> blenght == 8;		
		hburst == 3'b110 -> blenght == 16;
		hburst == 3'b111 -> blenght == 16;		
	}
	
	constraint order_c {
		solve hburst before blenght;
		solve hburst before undefburst_lenght;
		solve undefburst_lenght before blenght;
		solve blenght before hwdata;
    }

	constraint address_constraint {
		hsize == 3'b001 -> haddr[0]   == 1'b0;
		hsize == 3'b010 -> haddr[1:0] == 2'b0;
		hsize == 3'b011 -> haddr[2:0] == 3'b0;
		hsize == 3'b100 -> haddr[3:0] == 4'b0;
		hsize == 3'b101 -> haddr[4:0] == 5'b0;
		hsize == 3'b110 -> haddr[5:0] == 6'b0;
		hsize == 3'b111 -> haddr[6:0] == 7'b0;
	}

	constraint default_dyn_arr {
		hwdata.size() == max_length;	   
	}

	function void post_randomize();
		hwdata = new[blenght];
	endfunction 

	extern function new(string name = "ahb_tr");

endclass

function ahb_tr::new(string name = "ahb_tr");
	super.new(name);
endfunction


`endif //AHB_TR
