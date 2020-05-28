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

		.HCLK(ahb_vif.clk),
		//.PCLK(apb_vif.clk),
		.HRESETn(ahb_vif.reset_n),
		//.PRESETn(apb_vif.reset_n),
		.HADDR(ahb_vif.haddr),
        .HSIZE(ahb_vif.hsize),      
        .HWDATA(ahb_vif.hwdata),     
        .HWRITE(ahb_vif.hwrite),     
        .HRDATA(ahb_vif.hrdata),     
        .HREADY(ahb_vif.hready),     
        //.HRESP(ahb_vif.hresp),      
        .HSELAPB(ahb_vif.hsel),     
        .PADDR(apb_vif.paddr),     
        .PSEL(apb_vif.psel),       
        .PENABLE(apb_vif.penable),    
        .PWRITE(apb_vif.pwrite),     
        .PWDATA(apb_vif.pwdata),     
        .PRDATA(apb_vif.prdata),    
        .PREADY(apb_vif.pready)    
        //.PSLVERR(apb_vif.pslverr)     
    ); 

	initial begin
   		uvm_config_db#(virtual ahb_vif)::set(uvm_root::get(), "*", "ahb_vif", ahb_vif);
		uvm_config_db#(virtual apb_vif)::set(uvm_root::get(), "*", "ahb_vif", apb_vif);

    	$dumpfile("dump.vcd"); 
    	$dumpvars;
  	end
   
  	initial begin
   		run_test("ahb2apb_test");
 	end

endmodule 	