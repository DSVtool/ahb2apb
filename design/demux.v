/* 
Module:                 demux
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          apb 
Description:            Demultiplexer used for routing PREADY signal
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/

module demux #(
        parameter RATIO = 4,
        parameter logRATIO = 2
)
( 
        i_load, 
        i_load_sel, 
        o_load
);

input                   i_load;
input   [logRATIO-1:0]  i_load_sel;
output  [RATIO-1:0]     o_load; 

genvar i;
generate 
        for (i = 0; i < RATIO; i = i + 1) begin : demux_out 
                assign o_load[i] = i_load_sel == i ? i_load : 1'b0;
        end
endgenerate
endmodule