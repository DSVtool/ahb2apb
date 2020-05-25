/* 
Module:                 ahb_to_apb_bridge
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          - 
Description:            AHB slave which is used to bridge data to APB 
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/

module ahb_to_apb_bridge
#(
        parameter AHB_AW = 32,
        parameter APB_AW = 32,
        parameter AHB_DW = 32,
        parameter APB_DW = 8
)
(
        HCLK,       // AHB clock
        HRESETn,    // AHB reset
        HADDR,      // AHB address bus
        HSIZE,      // AHB transfer size
        //  HWDATA,     // AHB write data
        HWRITE,     // AHB write/read signal
        HRDATA,     // AHB read data
        HREADY,     // AHB ready signal
        HRESP,      // AHB response signal
        HSELAPB,    // AHB bridge select signal
    
        PADDR,      // APB address bus
        PSEL,       // APB slave select signal
        PENABLE,    // APB enable signal
        PWRITE,     // APB write/read signal
        //  PWDATA,     // APB write data
        PRDATA,     // APB read data
        PREADY,     // APB ready signal
        PSLVERR     // APB slave error signal
);

localparam RATIO = AHB_DW / APB_DW;

/* AHB signals */
input                   HCLK;
input                   HRESETn;
input [(AHB_AW-1):0]    HADDR;
input [2:0]             HSIZE;
//input [(AHB_DW-1):0]  HWDATA;
input                   HWRITE;
input                   HSELAPB;

output [(AHB_DW-1):0]   HRDATA;
output                  HREADY;
output                  HRESP;

/* APB signals */
input [(APB_DW-1):0]    PRDATA;
input                   PREADY;
input                   PSLVERR;

output [(APB_AW-1):0]   PADDR;
output                  PSEL;
output                  PENABLE;
output                  PWRITE;
//output [(APB_DW-1):0] PWDATA;

/* Internal wires */
/* AHB to APB */
wire [AHB_AW - 1 : 0]   w_haddr_ahb_to_apb;
wire [2:0]              w_hsize_ahb_to_apb;
wire                    w_hwrite_ahb_to_apb;

/* APB to AHB */
wire [AHB_DW - 1 : 0]   w_hrdata_apb_to_ahb;
wire                    w_hready_apb_to_ahb;
wire                    w_hresp_apb_to_ahb;

/* AHB to READ_TRANSFER_LOGIC */
wire                    w_ahb_to_start_read_transfer;

/* READ_TRANSFER_LOGIC to APB */
wire                    w_start_read_transfer_to_apb;

/* APB to HRDATA_R */
wire [RATIO - 1 : 0]    w_load_apb_to_hrdata_r;

/* HRDATA_R to AHB */
wire [AHB_DW - 1 : 0]   w_hrdata_hrdata_r_to_ahb;



/* module AHB */
ahb #(
        .AHB_AW(AHB_AW),
        .AHB_DW(AHB_DW),
        .APB_DW(APB_DW))
AHB (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .i_HADDR(HADDR),
        .o_HADDR(w_haddr_ahb_to_apb),
        .i_HSIZE(HSIZE),
        .o_HSIZE(w_hsize_ahb_to_apb),
        //  .HWDATA(HWDATA),
        .i_HWRITE(HWRITE),
        .o_HWRITE(w_hwrite_ahb_to_apb),
        .i_HRDATA(w_hrdata_hrdata_r_to_ahb),
        .o_HRDATA(HRDATA),
        .i_HREADY(w_hready_apb_to_ahb),
        .o_HREADY(HREADY),
        .i_HRESP(w_hresp_apb_to_ahb),
        .o_HRESP(HRESP),
        .i_HSEL(HSELAPB),
        .o_start_read_transfer(w_ahb_to_start_read_transfer)
);

/* module START_READ_TRANSFER */
positive_edge_detector START_READ_TRANSFER(
        .clk(HCLK),
        .in(w_ahb_to_start_read_transfer),
        .out(w_start_read_transfer_to_apb)
);

/* module HRDATA_R */
hrdata_reg #(
        .AHB_DW(AHB_DW),
        .APB_DW(APB_DW))
HRDATA_REG (
        .clk(HCLK),
        .rst(HRESETn),
        .i_PRDATA(PRDATA),
        .i_load(w_load_apb_to_hrdata_r),
        .o_HRDATA(w_hrdata_hrdata_r_to_ahb)
);

/* module APB */
apb #(
        .AHB_AW(AHB_AW),
        .APB_AW(APB_AW),
        .AHB_DW(AHB_DW),
        .APB_DW(APB_DW))
APB (
        .PCLK(HCLK),                        // APB clock
        .PRESETn(HRESETn),                  // APB reset
    
        .i_HADDR(w_haddr_ahb_to_apb),            // AHB address
        .i_HSIZE(w_hsize_ahb_to_apb),           // AHB size
        .i_HWRITE(w_hwrite_ahb_to_apb),         // AHB write/read
//        .i_HRDATA(w_hrdata_apb_to_ahb),         // AHB ready signal
        .o_HRESP(w_hresp_apb_to_ahb),           // AHB response signal
        .o_HREADY(w_hready_apb_to_ahb),         // AHB ready signal
        .i_start_transfer(w_start_read_transfer_to_apb),   // APB start transfer
    
        .o_PADDR(PADDR),                      // APB address bus
        .o_PENABLE(PENABLE),                  // APB enable signal
        .i_PRDATA(PRDATA),                    // APB read data
        .o_PSEL(PSEL),                        // APB slave select signal
        .i_PREADY(PREADY),                    // APB ready signal
        .o_PWRITE(PWRITE),                    // APB write/read signal 
        .i_PSLVERR(PSLVERR),                  // APB slave error signal
        //  .PWDATA(PWDATA)                     // APB write data
        .o_load(w_load_apb_to_hrdata_r)
);


endmodule