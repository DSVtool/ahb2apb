/* 
Module:                 apb
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          ahb_to_apb_bridge 
Description:            APB part of the bridge 
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/

module apb
#(
        parameter AHB_AW = 32,
        parameter APB_AW = 32,
        parameter AHB_DW = 32,
        parameter APB_DW = 8
)
(
        PCLK,                   // APB clock
        PRESETn,                // APB reset
        i_HADDR,                // AHB address
        i_HSIZE,                // AHB size
        //i_HWRITE,               // AHB write/read
        i_HWDATA,               // AHB write data
        o_HRESP,                // AHB response signal
        o_HREADY,               // AHB ready signal
        i_start_transfer,       // start of the APB transfer
        o_load,                 // load signal for HRDATA registers
        i_fifo_empty,           // fifo empty indicator
        
        o_PADDR,                // APB address bus
        o_PSEL,                 // APB slave select signal
        o_PENABLE,              // APB enable signal
        o_PWRITE,               // APB write/read signal
        o_PWDATA,               // APB write data
        //i_PRDATA,               // APB read data
        i_PREADY,               // APB ready signal
        i_PSLVERR               // APB slave error signal
        
        
        
);

/* Local parameters */
localparam APB_DW_B = APB_DW / 8;       // APB_DW in bytes
localparam RATIO = AHB_DW / APB_DW;     // AHB / APB data width
localparam logRATIO = clog2(RATIO);      // log2 RATIO

/* Signals */
/* AHB signals */
input [(AHB_AW-1):0]    i_HADDR;
input [2:0]             i_HSIZE;
//input                   i_HWRITE;
input [AHB_DW - 1 : 0]  i_HWDATA;
input                   i_start_transfer;
output [RATIO - 1 : 0]  o_load;
input                   i_fifo_empty;

// output reg [(AHB_DW-1):0] HRDATA;
output o_HREADY;
output o_HRESP;

/* APB signals */
input PCLK;
input PRESETn;
//input [(APB_DW -1):0] i_PRDATA;
input i_PREADY;
input i_PSLVERR;

output reg[(APB_AW-1):0] o_PADDR;
output reg o_PWRITE;
output reg o_PSEL;
output reg o_PENABLE;
output [(APB_DW - 1) : 0] o_PWDATA;

/* Local registers */
reg [7:0] r_cnt;
reg [7:0] r_hsize_byte_decoded;
reg [(logRATIO - 1):0] r_load_sel;
reg hready;


/* FSM registers and parameters */
localparam [1:0]
APB_IDLE = 2'b00,
APB_SETUP = 2'b01,
APB_ACCESS = 2'b10;

reg [1:0] r_current_state;
reg [1:0] r_next_state;

/* Log 2 function */
function integer clog2 (input integer n); 
integer j; 
begin 
        if(n > 1) begin
                n = n - 1;
                for (j = 0; n > 0; j = j + 1)        
                        n = n >> 1;
                clog2 = j;
        end else
        begin
                clog2 = 1;
        end
end
endfunction

/* APB state transition */
always @ (posedge PCLK, negedge PRESETn)
begin
        if(PRESETn == 0) begin
                r_current_state <= APB_IDLE;
        end else
        begin
                r_current_state <= r_next_state;
        end
end

/* APB next state logic */
always @ (*)
begin
        r_next_state = r_current_state;
        case(r_current_state)
                APB_IDLE: begin
                        if(i_start_transfer == 1'b1) begin
                                r_next_state = APB_SETUP;
                        end
                end
                
                APB_SETUP: begin
                        r_next_state = APB_ACCESS;
                end
                
                APB_ACCESS: begin
                        if(i_PREADY == 1'b1) begin
                                if(r_cnt == 0) begin
                                        r_next_state = APB_IDLE;
                                end else
                                begin
                                        r_next_state = APB_SETUP;
                                end
                        end
                end
                
                default: begin
                r_next_state = APB_IDLE;
                end
        endcase
end

/* APB output logic */
always @ (*)
begin
        case(r_current_state)
                APB_IDLE: begin
                        hready = 1'b1;
                        o_PSEL = 1'b0;
                        o_PENABLE = 1'b0;
                end
                        
                APB_SETUP: begin
                        hready = 1'b0;
                        o_PSEL = 1'b1;
                        o_PENABLE = 1'b0;
                end
                        
                APB_ACCESS: begin
                        hready = 1'b0;
                        o_PSEL = 1'b1;
                        o_PENABLE = 1'b1;
                end
                
                default: begin
                        hready = 1'b1;
                        o_PSEL = 1'b0;
                        o_PENABLE = 1'b0;
                end
        endcase
end

/* i_HSIZE byte decoder */
always @ (*)
begin
        case(i_HSIZE)
                3'b000: begin
                        r_hsize_byte_decoded = 1;
                end
                
                3'b001: begin
                        r_hsize_byte_decoded = 2;
                end
                
                3'b010: begin
                        r_hsize_byte_decoded = 4;
                end
                
                3'b011: begin
                        r_hsize_byte_decoded = 8;
                end
                
                3'b100: begin
                        r_hsize_byte_decoded = 16;
                end
                
                3'b101: begin
                        r_hsize_byte_decoded = 32;
                end
                
                3'b110: begin
                        r_hsize_byte_decoded = 64;
                end
                
                3'b111: begin
                        r_hsize_byte_decoded = 128;
                end
                
                default: begin
                        r_hsize_byte_decoded = 4;
                end
        endcase
end

/* Cycles counter and LOAD select */
always @ (posedge PCLK, negedge PRESETn)
begin
        
        if(PRESETn == 1'b0) begin
                r_cnt <= 0;
                r_load_sel <= 0;
        end else
        begin
                case(r_current_state) 
                        APB_IDLE: begin
                                r_load_sel <= 0;
                                if(r_hsize_byte_decoded > APB_DW_B) begin
                                        r_cnt <= r_hsize_byte_decoded;
                                end else
                                begin
                                        r_cnt <= APB_DW_B;
                                end
                        end
                        
                        APB_SETUP: begin
                                r_cnt <= r_cnt - APB_DW_B;
                        end
                        
                        APB_ACCESS: begin
                                if (i_PREADY == 1'b1 && r_cnt > 0) begin
                                        r_load_sel <= r_load_sel + 1'b1;
                                end
                        end
                endcase
        end
end

always @ (posedge PCLK)
begin
        if (i_fifo_empty == 1'b1) begin
                o_PWRITE <= 1'b0;
        end else
        begin
                o_PWRITE <= 1'b1;
        end
end

/* Assigning APB address */
always @ (posedge PCLK, negedge PRESETn)
begin
        if(PRESETn == 1'b0) begin
                o_PADDR <= 0;
        end else
        begin
                case(r_current_state)
                        APB_IDLE: begin
                                o_PADDR <= i_HADDR;  
                                case (APB_DW_B)
                                        2: begin
                                                o_PADDR [0] <= 1'b0;
                                        end
                
                                        4: begin
                                                o_PADDR [1:0] <= 2'b0;
                                        end
                                endcase
                        end
                
                        APB_ACCESS: begin
                                o_PADDR <= o_PADDR + APB_DW_B;
                        end
                endcase
        end
end

assign o_HRESP = i_PSLVERR;

generate
        if(RATIO > 1) begin
                hwdata_mux #(
                        .AHB_DW(AHB_DW),
                        .APB_DW(APB_DW),
                        .RATIO(RATIO),
                        .logRATIO(logRATIO)
                )
                HWDATA_MUX(
                        .in(i_HWDATA),
                        .sel(r_load_sel),
                        .out(o_PWDATA)
                );
        end else
        begin
                assign o_PWDATA = i_HWDATA;
        end
endgenerate
/* load demultiplexer */
demux #(
        .RATIO(RATIO),
        .logRATIO(logRATIO)
)
load_demux(
        .i_load(i_PREADY),
        .i_load_sel(r_load_sel),
        .o_load(o_load)
);

/* positive edge detector for hready */
positive_edge_detector hready_detector(
        .clk(PCLK),
        .in(hready),
        .out(o_HREADY)
);

endmodule