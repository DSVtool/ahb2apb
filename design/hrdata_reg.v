/* 
Module:                 hrdata_reg
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          ahb_to_apb_module 
Description:            Register for storing HRDATA, contains AHB_DW/APB_DW registers of APB_DW width
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/

module hrdata_reg  #(
        parameter AHB_DW = 32,
        parameter APB_DW = 8
) 
(
        clk,
        rst,
        i_PRDATA,
        i_load,
        o_HRDATA
);

localparam RATIO = AHB_DW / APB_DW;

input                   clk;
input                   rst;
input [APB_DW - 1 : 0]  i_PRDATA;
input [RATIO - 1 : 0]   i_load;
output [AHB_DW - 1 : 0] o_HRDATA;



/* Generate of AHB_DW / APB_DW registers */
genvar i;
generate
        for (i = 0; i < RATIO; i = i + 1) begin : regs
                data_reg #(
                        .APB_DW(APB_DW)
                )
                r_data (
                        .clk(clk),
                        .rst(rst),
                        .i_load(i_load[i]),
                        .i_data(i_PRDATA),
                        .o_data(o_HRDATA[((i+1)*APB_DW - 1): i*APB_DW])
                );
        end
endgenerate
endmodule



