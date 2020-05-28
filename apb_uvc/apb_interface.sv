// File name: 			APB_Interface.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module interface
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_VIF
`define APB_VIF
  
interface apb_vif #(parameter APB_BUS_W = 32, APB_ADDR_W = 32) (input bit clk, input bit reset_n);

	logic [APB_ADDR_W-1:0] paddr;
	logic [APB_BUS_W-1:0] pwdata;
	logic [APB_BUS_W-1:0] prdata;	 		
    logic [0:0]		 pwrite;
    logic [0:0]  	 penable;
    //logic [0:0]  	 pstrobe;	
    logic [0:0]  	 pready;
    logic [0:0]  	 psel;

		
	clocking mst_cb @(posedge clk);
		input  paddr;
		input  pwdata;	
		input  pwrite;
		input  penable;
	//	input  pstrobe;
		input  psel;				
		output pready;		
		output prdata;	
	endclocking
	
	clocking mon_cb @(posedge clk);
		input paddr;
		input pwdata;
		input prdata;
	//	input pstrobe; 		
		input pwrite;
		input penable;
		input pready;
		input psel;
	endclocking

endinterface


`endif //APB_VIF