// File name: 			AHB_Interface.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module interface
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_VIF
`define AHB_VIF
  
interface ahb_vif #(parameter AHB_DW = 32, AHB_AW = 32) (input bit clk, input bit reset_n);

	logic [AHB_AW-1:0] haddr;
	logic [AHB_DW-1:0] hwdata;
	logic [AHB_DW-1:0] hrdata;	
    logic [2:0]  hburst;
    logic [2:0]  hsize; 		
    logic [0:0]	 hwrite;
    logic [0:0]  hready;
    logic [1:0]  htrans;
	//logic [0:0]  hresp;				
    //logic [0:0]  hexokay;
	
	clocking mst_cb @(posedge clk);
		output haddr;
		output hwdata;
		output hburst;
		output hsize; 		
		output hwrite;
		output htrans;
		input  hready;	
		input  hrdata;	
		//input  hresp;				
		//input  hexokay;
	endclocking
	
	clocking mon_cb @(posedge clk);
		input haddr;
		input hwdata;
		input hburst;
		input hsize; 		
		input hwrite;
		input hready;
		input hrdata;	
		input htrans;
		//input hresp;				
		//input hexokay;
	endclocking

endinterface

`endif //AHB_VIF