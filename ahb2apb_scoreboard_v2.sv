// File name: 			AHB2APB_Scoreboard.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module scoreboard
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_SCOREBOARD
`define AHB2APB_SCOREBOARD

class ahb2apb_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(ahb2apb_scoreboard)
   
    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_ahb)

	ahb_tr #(`AHB_BUS_W,`AHB_ADDR_W) ahbtrans;
	apb_tr #(`APB_BUS_W,`APB_ADDR_W) apbtrans;

	ahb_tr #(`AHB_BUS_W,`AHB_ADDR_W) ahb_item_queue [$];    // stores incoming items from the ahb_mon
    apb_tr #(`APB_BUS_W,`APB_ADDR_W) apb_item_queue [$];    // stores incoming items from the apb_mon
   

    uvm_analysis_imp_apb #(apb_tr #(`AHB_BUS_W,`AHB_ADDR_W), ahb2apb_scoreboard) apb_export;   
    uvm_analysis_imp_ahb #(ahb_tr #(`APB_BUS_W,`APB_ADDR_W), ahb2apb_scoreboard) ahb_export;

    function write_ahb(ahb_tr #(`AHB_BUS_W,`AHB_ADDR_W) tr);
    	ahb_item_queue.push_front(tr);
 	endfunction

  	function write_apb(apb_tr #(`APB_BUS_W,`APB_ADDR_W) tr);
    	apb_item_queue.push_front(tr);
  	endfunction
  	
    extern virtual function void build_phase(uvm_phase phase);
	extern function new(string name = "ahb2apb_scoreboard", uvm_component parent);				

    extern virtual function wdata_compare();
	extern virtual function rdata_compare();
	extern virtual task run(); 

endclass 

function ahb2apb_scoreboard::new (string name, uvm_component parent);
	super.new(name, parent); 
endfunction  

function void ahb2apb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
        ahb_export  = new("ahb_export", this);
        apb_export  = new("apb_export", this);
endfunction


task ahb2apb_scoreboard::run();
	forever begin
				ahbtrans = ahb_tr #(`HDATA_W,`HADDR_W)::type_id::create("ahbtrans");
 		        ahbtrans = ahb_item_queue.pop_back();
				if(ahbtrans.hwrite)
					wdata_compare();
				else
					rdata_compare();
			end
endtask 



function ahb2apb_scoreboard::wdata_compare();					

	int i,j; 
	int data_buff[];
	int arr_size;

	if(ahbtrans.hsize > `AHB_BUS_W)
		begin
			arr_size = 8*2**ahbtrans.hsize; 
			data_buff = new[arr_size]; 
			while (ahbtrans.htrans !== 2 && ahbtrans.htrans !== 1)
				for (i=0; i < arr_size; i=+`AHB_BUS_W)
					begin
						apb_fifo.get(apbtrans);
						data_buff[i+`AHB_BUS_W:i] = apbtrans.pwdata;
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
	else if (ahbtrans.hsize < `AHB_BUS_W)
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

function ahb2apb_scoreboard::rdata_compare();					

	int i,j; 
	int data_buff[];
	int arr_size;

	if(ahbtrans.hsize > `AHB_BUS_W)
		begin
			arr_size = 8*2**ahbtrans.hsize; 
			data_buff = new[arr_size]; 
			while (ahbtrans.htrans !== 2 && ahbtrans.htrans !== 1)
				for (i=0; i < arr_size; i=+`AHB_BUS_W)
					begin
						apb_fifo.get(apbtrans);
						data_buff[i+`AHB_BUS_W:i] = apbtrans.prdata;
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
	else if (ahbtrans.hsize < AHB_BUS_W)
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

`endif //AHB2APB_SCOREBOARD