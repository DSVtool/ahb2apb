// File name: 			AHB_Transaction.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module transaction
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef АHB_TR
`define АHB_TR

class ahb_tr #(parameter AHB_DW = 32, AHB_AW = 32)  extends uvm_sequence_item;

	rand bit [AHB_AW:0] haddr;				// All transfers in a burst must be aligned to the address boundary equal to the size of the transfer. Page34
		 bit [AHB_DW:0] hrdata;	
    rand bit [2:0]  hburst;
    rand bit [2:0]  hsize; 				// The transfer size set by HSIZE must be less than or equal to the width of the data bus.			
    rand bit [1:0]  htrans;  			// 00-IDLE / 01-BUSY / 10-NONSEQUENTAL / 11-SEQUENTAL
	rand bit 		hwrite;
   		 bit 		hready;
   		 bit 		hsel;
	rand int 		tr_delay;
		 int 		blenght;
	rand int		undefburst_lenght;
	
	rand bit [AHB_DW-1:0][blenght:0]  hwdata;   
	
	ETransPhase 	transaction_phase; 

	`uvm_object_param_utils_begin(ahb_tr)
		`uvm_field_int (haddr, 			   UVM_ALL_ON)
		`uvm_field_int (hwdata, 		   UVM_ALL_ON)
		`uvm_field_int (hrdata, 		   UVM_ALL_ON)
		`uvm_field_int (hburst, 		   UVM_ALL_ON)
		`uvm_field_int (hsize, 			   UVM_ALL_ON)
		`uvm_field_int (hwrite,   		   UVM_ALL_ON)
		`uvm_field_int (hready, 		   UVM_ALL_ON)
		`uvm_field_int (hsel,    		   UVM_ALL_ON)
		`uvm_field_int (hresp, 	   		   UVM_ALL_ON)
		`uvm_field_int (hexokay,   		   UVM_ALL_ON)
		`uvm_field_int (undefburst_lenght, UVM_ALL_ON)
		`uvm_field_int (htrans,			   UVM_ALL_ON)		
		`uvm_field_int (blenght,  		   UVM_ALL_ON)
		`uvm_field_int (tr_delay,		   UVM_ALL_ON)
		`uvm_field_enum(ETransPhase, transaction_phase, UVM_ALL_ON);
	`uvm_object_utils_end
	    
    constraint general_c {	
    	hsize < $clog2(AHB_DW)-2;
		tr_delay inside {[0:60]};
		soft hsel == 1;
	}
	
	constraint undefburst_c {	
		if( hburst !== 1)
			undefburst_lenght == 0;
	}
	
	constraint blenght_c{
		(hburst == 3'b000) -> blenght == 1     	
		(hburst == 3'b001) -> blength == undefburst_lenght;		 		// "undefined" length INC burst
		(hburst == 3'b010) -> blength == 4;		
		(hburst == 3'b011) -> blength == 4;		
		(hburst == 3'b100) -> blength == 8;		
		(hburst == 3'b101) -> blength == 8;		
		(hburst == 3'b110) -> blength == 16;
		(hburst == 3'b111) -> blength == 16;		
	}
	
	constraint order_c {
		solve hburst before blenght;
		solve undefburst_c before blenght;
		solve blenght before hwdata;
    }

	constraint address_constraint {
		(hsize == 3'b001) -> addr[0]   == 1'b0;
		(hsize == 3'b010) -> addr[1:0] == 2'b0;
		(hsize == 3'b011) -> addr[2:0] == 3'b0;
		(hsize == 3'b100) -> addr[3:0] == 4'b0;
		(hsize == 3'b101) -> addr[4:0] == 5'b0;
		(hsize == 3'b110) -> addr[5:0] == 6'b0;
		(hsize == 3'b111) -> addr[6:0] == 7'b0;
	}

	extern function new(string name = "ahb_tr");

endclass

function ahb_tr::new(string name = "ahb_tr");
	super.new(name);
endfunction

`endif //AHB_TR
