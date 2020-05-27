/* 
Module:                 data_reg
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          hrdata_reg 
Description:            Single register, APB_DW width 
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/

module data_reg #(
        parameter APB_DW = 8
)
(
        clk,
        rst,
        i_load,
        i_data,
        o_data
);
        
input                           clk;
input                           rst;
input                           i_load;
input [APB_DW - 1 : 0]          i_data;
output reg [APB_DW - 1 : 0]     o_data;

always @ (posedge clk, negedge rst)
begin
        if (rst == 1'b0) begin
                o_data <= 0;
        end else
        begin
                if(i_load == 1'b1) begin
                        o_data <= i_data;
                end
        end
end
endmodule