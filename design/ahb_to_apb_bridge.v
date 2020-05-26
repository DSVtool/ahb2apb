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
        parameter APB_DW = 8,
        parameter FIFO_SIZE = 8
)
(
        HCLK,       // AHB clock
        HRESETn,    // AHB reset
        HADDR,      // AHB address bus
        HSIZE,      // AHB transfer size
        HWDATA,     // AHB write data
        HWRITE,     // AHB write/read signal
        HRDATA,     // AHB read data
        HREADY,     // AHB ready signal
        HRESP,      // AHB response signal
        HSELAPB,    // AHB bridge select signal
    
        PADDR,      // APB address bus
        PSEL,       // APB slave select signal
        PENABLE,    // APB enable signal
        PWRITE,     // APB write/read signal
        PWDATA,     // APB write data
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
input [(AHB_DW-1):0]    HWDATA;
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
output [(APB_DW-1):0]   PWDATA;

/* Internal wires */
/* AHB to APB */

wire                    w_hwrite_ahb_to_apb;

/* APB to AHB */
wire [AHB_DW - 1 : 0]   w_hrdata_apb_to_ahb;



/* AHB to READ_TRANSFER_LOGIC */
//wire                    w_ahb_to_start_read_transfer;

/* READ_TRANSFER_LOGIC to APB */
//wire                    w_start_read_transfer_to_apb;

wire [AHB_AW - 1 : 0]   w_haddr;
wire [2:0]              w_hsize;
wire                    w_hready;
wire                    w_fifo_empty;
wire                    w_fifo_full;

wire [AHB_DW - 1 : 0]   w_hrdata_hrdata_r_to_ahb;
wire                    w_hresp_apb_to_ahb;
wire                    w_read_transfer_ahb_to_internal_logic;
wire                    w_write_transfer_ahb_to_fifo;
wire [AHB_AW - 1 : 0]   w_haddr_fifo_to_internal_logic;
wire [AHB_DW - 1 : 0]   w_hwdata_fifo_to_apb;
wire [2:0]              w_hsize_fifo_to_internal_logic;
wire [AHB_AW - 1 : 0]   w_haddr_internal_logic_to_apb;
wire [2:0]              w_hsize_internal_logic_to_apb;
wire                    w_start_transfer_internal_logic_to_apb;
wire [RATIO - 1 : 0]    w_load_apb_to_hrdata_r;

   




/* module AHB */
ahb #(
        .AHB_AW(AHB_AW),
        .AHB_DW(AHB_DW),
        .APB_DW(APB_DW))
AHB (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .i_HADDR(HADDR),
        .o_HADDR(w_haddr),
        .i_HSIZE(HSIZE),
        .o_HSIZE(w_hsize),
        //  .HWDATA(HWDATA),
        .i_HWRITE(HWRITE),
        //.o_HWRITE(w_hwrite_ahb_to_apb),
        .i_HRDATA(w_hrdata_hrdata_r_to_ahb),
        .o_HRDATA(HRDATA),
        .i_HREADY(w_hready),
        .o_HREADY(HREADY),
        .i_HRESP(w_hresp_apb_to_ahb),
        .o_HRESP(HRESP),
        .i_HSEL(HSELAPB),
        .o_start_read_transfer(w_read_transfer_ahb_to_internal_logic),
        .o_start_write_transfer(w_write_transfer_ahb_to_fifo),
        .i_fifo_full(w_fifo_full),
        .i_fifo_empty(w_fifo_empty)
        //.i_HWDATA(HWDATA)
);

/* module START_READ_TRANSFER */
/*
positive_edge_detector START_READ_TRANSFER(
        .clk(HCLK),
        .in(w_ahb_to_start_read_transfer),
        .out(w_start_read_transfer_to_apb)
); */

/* module FIFO_MEMORY */
fifo_memory #(
        .AHB_AW(AHB_AW),
        .AHB_DW(AHB_DW),
        .FIFO_SIZE(FIFO_SIZE))
FIFO_MEMORY(
        .clk(HCLK),
        .rst_n(HRESETn),
        .i_haddr(w_haddr),
        .i_hwdata(HWDATA),
        .i_hsize(w_hsize),
        .o_haddr(w_haddr_fifo_to_internal_logic),
        .o_hwdata(w_hwdata_fifo_to_apb),
        .o_hsize(w_hsize_fifo_to_internal_logic),
        .o_fifo_full(w_fifo_full),
        .o_fifo_empty(w_fifo_empty),
        .i_write(w_write_transfer_ahb_to_fifo),
        .i_read(w_hready)
);

/* module INTERNAL_LOGIC */
internal_logic #(
        .AHB_AW(AHB_AW),
        .AHB_DW(AHB_DW))
INTERNAL_LOGIC(
        .hclk(HCLK),
        .rst_n(HRESETn),
        .i_haddr_read(w_haddr),
        .i_haddr_write(w_haddr_fifo_to_internal_logic),
        .i_hsize_read(w_hsize),
        .i_hsize_write(w_hsize_fifo_to_internal_logic),
        .i_hready(w_hready),
        .o_haddr(w_haddr_internal_logic_to_apb),
        .o_hsize(w_hsize_internal_logic_to_apb),
        .i_fifo_empty(w_fifo_empty),
        .i_read_transfer(w_read_transfer_ahb_to_internal_logic),
        .o_start_transfer(w_start_transfer_internal_logic_to_apb)
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
    
        .i_HADDR(w_haddr_internal_logic_to_apb),            // AHB address
        .i_HSIZE(w_hsize_internal_logic_to_apb),           // AHB size
//        .i_HWRITE(w_hwrite_ahb_to_apb),         // AHB write/read
        .i_HWDATA(w_hwdata_fifo_to_apb),         // AHB ready signal
        .o_HRESP(w_hresp_apb_to_ahb),           // AHB response signal
        .o_HREADY(w_hready),         // AHB ready signal
        .i_start_transfer(w_start_transfer_internal_logic_to_apb),   // APB start transfer
        .i_fifo_empty(w_fifo_empty),
    
        .o_PADDR(PADDR),                      // APB address bus
        .o_PENABLE(PENABLE),                  // APB enable signal
        //.i_PRDATA(PRDATA),                    // APB read data
        .o_PSEL(PSEL),                        // APB slave select signal
        .i_PREADY(PREADY),                    // APB ready signal
        .o_PWRITE(PWRITE),                    // APB write/read signal 
        .i_PSLVERR(PSLVERR),                  // APB slave error signal
        .o_PWDATA(PWDATA),                    // APB write data
        .o_load(w_load_apb_to_hrdata_r)
);


endmodule