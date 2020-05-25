// File name: 			AHB2APB_Testbench.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module Top Testbench
// File history: 		0.1  - Dimitrije S. - Inital version.

module ahb2apb_testbench;

	import env_pkg::*;
	import uvm_pkg::*;

	`include "ahb2apb_test.sv"

	bit clk;
	bit reset_n;

	ahb_vif #(`AHB_BUS_W,`AHB_ADDR_W) 	ahb_vif(clk,reset_n);
	apb_vif #(`APB_BUS_W,`AHB_ADDR_W)	apb_vif(clk,reset_n);

	/* Clock Generation*/

	always #5 
		clk = ~clk;

	/* Generate reset_n */

	initial 
		begin
			reset_n = 1;
			#5;
			reset_n = 0;
		end 

	/* DUT instance */

	ahb_to_apb_bridge DUT(

		.HCLK(ifahbagnt.clk),
		.PCLK(ifapbagnt.clk),
		.HRESETn(ifahbagnt.reset_n),
		.PRESETn(ifapbagnt.reset_n),
		.HADDR(ifahbagnt.haddr),
        .HSIZE(ifahbagnt.hsize),      
        .HWDATA(ifahbagnt.hwdata),     
        .HWRITE(ifahbagnt.hwrite),     
        .HRDATA(ifahbagnt.hrdata),     
        .HREADY(ifahbagnt.hready),     
        .HRESP(ifahbagnt.hresp),      
        .HSELAPB(ifahbagnt.hsel),     
        .PADDR(ifapbagnt.paddr),     
        .PSEL(ifapbagnt.psel),       
        .PENABLE(ifapbagnt.penable),    
        .PWRITE(ifapbagnt.pwrite),     
        .PWDATA(ifapbagnt.pwdata),     
        .PRDATA(ifapbagnt.prdata),    
        .PREADY(ifapbagnt.pready),    
        .PSLVERR(ifapbagnt.pslverr)     
        
	); 

	initial begin
   		uvm_config_db#(virtual ahb_vif)::set(uvm_root::get(), "apb_agnt.*", "vif", ifahbagnt);
		uvm_config_db#(virtual apb_vif)::set(uvm_root::get(), "apb_agnt.*", "vif", ifapbagnt);

    	$dumpfile("dump.vcd"); 
    	$dumpvars;
  	end
   
  	initial begin
   		run_test();
 	end



endmodule 	