// File name: 			AHB2APB_Env_Package.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB top package
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef ENV_PKG
`define ENV_PKG

`include "ahb_interface.sv"
`include "apb_interface.sv"

package env_pkg;  

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	import ahb_pkg::*;
	import apb_pkg::*;

	`include "bridge_macros.sv"

	`include "ahb2apb_enviroment.sv"
	`include "ahb2apb_scoreboard.sv"
	`include "ahb2apb_sequence.sv"
	`include "ahb2apb_virtual_sequencer.sv"
	`include "ahb2apb_test.sv"

endpackage

`endif //ENV_PKG
