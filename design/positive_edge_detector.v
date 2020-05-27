/* 
Module:                 positive_edge_detector
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          ahb_to_apb_bridge, apb 
Description:            Detecting positive edge 
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/


module positive_edge_detector(
	clk,
	in,
	out
);

input clk;
input in;
output reg out;

reg in_delay;
 

always @ (posedge clk)
begin
	in_delay <= in;
end

always @ (posedge clk)
begin
	out <= in & ~in_delay;
end
endmodule