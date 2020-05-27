/* 
Module:                 ahb
Version:                0.1
Date:                   05/13/2020 
Project:                AHB to APB bridge 
Parent module:          ahb_to_apb_bridge 
Description:            AHB part of the bridge 
Author:                 Vuk Popovic     email:  vukp@thevtool.com 
Company:                Vtool
Relevant documents: 

Version history:
0.1     Vuk Popovic     05/13/2020      Initial version
*/


module ahb
#(
	parameter AHB_AW = 32,
	parameter AHB_DW = 32,
        parameter APB_DW = 8
)
(
	HCLK,				// AHB clock
	HRESETn,			// AHB reset
	i_HADDR,			// AHB address		
	o_HADDR,			// sampled address
	i_HWRITE,			// AHB write/read
	//o_HWRITE,			// sampled write/read
	i_HSIZE,			// AHB transfer size
	o_HSIZE,			// sampled transfer size
	o_HREADY,			// AHB ready out signal
	i_HREADY,			// AHB ready in signal
	i_HSEL,			        // AHB bridge select signal
	o_start_read_transfer, 	        // read transaction indicator (start of the APB read transfer)
        o_start_write_transfer,         // write transaction indicator
        i_fifo_full,                    // FIFO full indicator
        i_fifo_empty,                   // FIFO empty indicator
	i_HRESP,			// AHB response signal
	o_HRESP,			// AHB response signal output
	i_HRDATA,		        // AHB read data
	o_HRDATA			// AHB read data output
        //i_HWDATA                        // AHB write data
	
	

);

/* Signals */
input                   HCLK;
input                   HRESETn;
input [(AHB_AW-1):0]    i_HADDR;
input [2:0]             i_HSIZE;
input                   i_HWRITE;
input                   i_HREADY;
input                   i_HSEL;
input [(AHB_DW-1):0]    i_HRDATA;
input                   i_HRESP;
//input [AHB_DW - 1 : 0]  i_HWDATA;
input                   i_fifo_full;
input                   i_fifo_empty;

output reg [(AHB_AW-1):0] o_HADDR;
output reg [2:0] o_HSIZE;
//output reg o_HWRITE;
output reg o_start_read_transfer;
output reg o_start_write_transfer;
output reg o_HREADY;
output reg[(AHB_DW-1):0] o_HRDATA;
output o_HRESP;



/* FSM registers and parameters */
localparam [1:0]
AHB_IDLE = 2'b00,
AHB_READ = 2'b01,
AHB_WRITE = 2'b10;

reg [1:0] r_current_state;
reg [1:0] r_next_state;

/* AHB state transition */
always @ (posedge HCLK, negedge HRESETn)
begin
	if(HRESETn == 0) begin
		r_current_state <= AHB_IDLE;
	end else
	begin
		r_current_state <= r_next_state;
	end
end

/* AHB next state logic */
always @ (*)
begin
	r_next_state = r_current_state;
	case(r_current_state)
		AHB_IDLE: begin
			if (i_HSEL == 1'b1) begin 
				if (i_HWRITE == 1'b1) begin
                                        r_next_state = AHB_WRITE;
                                end else
                                begin
                                        r_next_state = AHB_READ;
                                end
			end
                end
		
		AHB_READ: begin
			if(i_HREADY == 1'b1 && i_fifo_empty == 1'b1) begin
                                if (i_HSEL == 1'b1) begin
                                        if (i_HWRITE == 1'b1) begin
                                                r_next_state = AHB_WRITE;
                                        end
                                end else
                                begin
                                        r_next_state = AHB_IDLE;
                                end
			end
		end
                
                AHB_WRITE: begin
                        if (i_fifo_full == 1'b0) begin
                                if (i_HSEL == 1'b0) begin
                                        r_next_state = AHB_IDLE;
                                end else
                                begin
                                        if (i_HWRITE == 1'b0) begin
                                                r_next_state = AHB_READ;
                                        end
                                end
                        end
                end
		
		default: begin
			r_next_state = AHB_IDLE;
		end
	endcase
end

/* AHB output logic */
always @ (*)
begin
	case(r_current_state)
		AHB_IDLE: begin
			o_start_read_transfer = 1'b0;
			o_HREADY = 1'b1;
                        o_start_write_transfer = 1'b0;
		end
		
		AHB_READ: begin
			o_HREADY = 1'b0;
			o_start_read_transfer = 1'b1;
                        o_start_write_transfer = 1'b0;
		end
                
                AHB_WRITE: begin
                        o_start_read_transfer = 1'b0;
                        o_start_write_transfer = 1'b1;
                        if (i_fifo_full == 1'b1) begin
                                o_HREADY = 1'b0;
                        end else
                        begin
                                o_HREADY = 1'b1;
                        end
                end
		
		default: begin
			o_start_read_transfer = 1'b0;
			o_HREADY = 1'b1;
		end
	endcase
end

/* Sampling i_HADDR,i_HSIZE,i_HWRITE */
always @ (posedge HCLK, negedge HRESETn)
begin
        if(HRESETn == 1'b0) begin
		o_HADDR <= 0;
		o_HSIZE <= 0;
		//o_HWRITE <= 0;
	end else
	begin
		/* if(i_HSEL == 1'b1 && o_HREADY == 1'b1 && i_HWRITE == 1'b0) begin
			o_HADDR <= i_HADDR;
			o_HSIZE <= i_HSIZE;
			o_HWRITE <= i_HWRITE;
		end */
                if (o_HREADY == 1'b1 && i_HSEL == 1'b1) begin
                        o_HADDR <= i_HADDR;
			o_HSIZE <= i_HSIZE;
			//o_HWRITE <= i_HWRITE;
                end
	end
end

assign o_HRESP = i_HRESP;

/* i_HRDATA sorting data */
always @ (*)
begin
        if(o_HSIZE < APB_DW) begin
                case(APB_DW)
                        
			16: begin
                                if (o_HADDR[0] == 1'b1) begin
                                        o_HRDATA = {i_HRDATA[7:0],i_HRDATA[AHB_DW - 1 : 8]};
                                end else
                                begin
                                        o_HRDATA = i_HRDATA;
                                end
                        end
                        
                        32: begin
                                case (o_HADDR[1:0])
                                        2'b00: begin
                                                o_HRDATA = i_HRDATA;
                                        end
                                        
                                        2'b01: begin
                                                o_HRDATA = {i_HRDATA[7:0],i_HRDATA[AHB_DW - 1 : 8]};
                                        end
                                        
                                        2'b10: begin
                                                o_HRDATA = {i_HRDATA[15:0],i_HRDATA[AHB_DW - 1 : 16]};
                                        end
                                        
                                        2'b11: begin
                                                o_HRDATA = {i_HRDATA[23:0],i_HRDATA[AHB_DW - 1 : 24]};
                                        end
                                        
                                        default: begin
                                                o_HRDATA = i_HADDR;
                                        end
                                endcase
                        end
                        
                        default: begin
                                o_HRDATA = i_HRDATA;
                        end
                endcase
        end else
        begin
                o_HRDATA = i_HRDATA;
        end
end
endmodule