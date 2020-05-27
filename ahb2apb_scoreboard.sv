// File name: 			AHB2APB_Scoreboard.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module scoreboard
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_SCOREBOARD
`define AHB2APB_SCOREBOARD

class ahb2apb_scoreboard extends uvm_scoreboard;

	//int apb_width = `APB_BUS_W;

	`uvm_component_utils(ahb2apb_scoreboard)

	ahb_tr #(`AHB_BUS_W,`AHB_ADDR_W) ahbtrans;
	apb_tr #(`APB_BUS_W,`APB_ADDR_W) apbtrans;

    uvm_analysis_export #(ahb_tr #(`AHB_BUS_W,`AHB_ADDR_W)) ahb_export;
    uvm_analysis_export #(apb_tr #(`APB_BUS_W,`APB_ADDR_W)) apb_export;

   	extern virtual function void build_phase(uvm_phase phase);
	extern function new(string name = "ahb2apb_scoreboard", uvm_component parent);				

   // extern virtual function wdata_compare();
	//extern virtual function rdata_compare();
	//extern virtual task run(); 

endclass 

function ahb2apb_scoreboard::new (string name, uvm_component parent);
	super.new(name, parent);

	ahbtrans = new("ahbrtans");
	apbtrans = new("apbrtans");

endfunction  

function void ahb2apb_scoreboard::build_phase(uvm_phase phase);
        super.build_phase(phase);

        ahb_export  = new("ahb_export", this);
        apb_export  = new("apb_export", this);
 
       // ahb_fifo    = new("ahb_fifo", this);
       // apb_fifo    = new("apb_fifo", this);

endfunction

/*
task ahb2apb_scoreboard::run();
		forever 
			begin
				ahb_fifo.get(ahbtrans);
				if(ahbtrans.hwrite)
					wdata_compare();
				else
					rdata_compare();
			end
endtask 
*/

/*
function ahb2apb_scoreboard::wdata_compare();					

	int i,j; 
	int data_buff[];
	int arr_size;

	if(ahbtrans.hsize > apb_width)
		begin
			arr_size = 8*2**ahbtrans.hsize; 
			data_buff = new[arr_size]; 
			while (ahbtrans.htrans !== 2 && ahbtrans.htrans !== 1)
				for (i=0; i < arr_size; i=+apb_width)
					begin
						apb_fifo.get(apbtrans);
						data_buff[i+apb_width:i] = apbtrans.pwdata;
					end
			if(data_buff == ahbtrans.hwdata)
				begin
					`uvm_info("wdata_compare", {"Test: Pass!"}, UVM_LOW);
				end
			else 
				begin
					`uvm_info("wdata_compare", {"Test: Fail!"}, UVM_LOW);
				end
		end		
	else if (ahbtrans.hsize < apb_width)
		begin
			//addlater
		end
	else 
		begin
			if(ahbtrans.prdata == ahbtrans.hrdata)
				begin	
					`uvm_info("rdata_compare", {"Test: Pass!"}, UVM_LOW);
				end
			else 
				begin
					`uvm_info("rdata_compare", {"Test: Fail!"}, UVM_LOW);
				end
		end

endfunction	
*/

/*
function ahb2apb_scoreboard::rdata_compare();					

	int i,j; 
	int data_buff[];
	int arr_size;

	if(ahbtrans.hsize > apb_width)
		begin
			arr_size = 8*2**ahbtrans.hsize; 
			data_buff = new[arr_size]; 
			while (ahbtrans.htrans !== 2 && ahbtrans.htrans !== 1)
				for (i=0; i < arr_size; i=+apb_width)
					begin
						apb_fifo.get(apbtrans);
						data_buff[i+apb_width:i] = apbtrans.prdata;
					end
			if(data_buff == ahbtrans.hrdata)
				begin
					`uvm_info("rdata_compare", {"Test: Pass!"}, UVM_LOW);
				end
			else 
				begin	
					`uvm_info("rdata_compare", {"Test: Fail!"}, UVM_LOW);
				end
			data_buff.delete;
		end
	else if (ahbtrans.hsize < apb_width)
		begin
			//addlater
		end
	else 
		begin
			if(ahbtrans.prdata == ahbtrans.hrdata)
				begin
					`uvm_info("rdata_compare", {"Test: Pass!"}, UVM_LOW);
				end
			else 
				begin
					`uvm_info("rdata_compare", {"Test: Fail!"}, UVM_LOW);
				end
		end

endfunction
*/	


`endif //AHB2APB_SCOREBOARD