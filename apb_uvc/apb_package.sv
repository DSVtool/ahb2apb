// File name: 			APB_Package.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    APB VIP module package
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef APB_PKG
`define APB_PKG

`include "apb_interface.sv"

package apb_pkg;  

	import uvm_pkg::*;
	`include "uvm_macros.svh" 

	`include "apb_transaction.sv"
	`include "apb_master_driver.sv"
	`include "apb_monitor.sv"
	`include "apb_master_sequencer.sv"
	`include "apb_master_agent.sv"

endpackage

`endif //apb_pkg
