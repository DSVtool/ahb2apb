// File name: 			AHB_Interface.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module interface
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_VIF
`define AHB_VIF
  
interface ahb_vif #(parameter AHB_BUS_W = 32, AHB_ADDR_W = 32) (input bit clk, input bit reset_n);

	logic [AHB_ADDR_W-1:0] haddr;
	logic [AHB_BUS_W-1:0] hwdata;
	logic [AHB_BUS_W-1:0] hrdata;	
    logic [2:0]  hburst;
    logic [2:0]  hsize; 		
    logic [0:0]	 hwrite;
    logic [0:0]  hready;
    logic [1:0]  htrans;
    logic [0:0]	 hsel;
	//logic [0:0]  hresp;				
    //logic [0:0]  hexokay;
	
	clocking mst_cb @(posedge clk);
		output haddr;
		output hwdata;
		output hburst;
		output hsize; 		
		output hwrite;
		output htrans;
		output hsel;
		input  hrdata;
		input  hready;	
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
		input hsel;
		//input hresp;				
		//input hexokay;
	endclocking

endinterface


`endif //AHB_VIF