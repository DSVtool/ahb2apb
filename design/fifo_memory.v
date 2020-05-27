
module fifo_memory #(
        parameter AHB_AW = 32,
        parameter AHB_DW = 32,
        parameter FIFO_SIZE = 8
)
(
        clk,
        rst_n,
        i_haddr,
        i_hwdata,
        i_hsize,
        o_haddr,
        o_hwdata,
        o_hsize,
        o_fifo_full,
        o_fifo_empty,
        i_write,
        i_read
        
);

/* Local parameters */
localparam FIFO_WIDTH = AHB_AW + AHB_DW + 3;
localparam logSIZE = clog2(FIFO_SIZE);

/* Input signals */
input                   clk;
input                   rst_n;
input [AHB_AW - 1 : 0]  i_haddr;
input [AHB_DW - 1 : 0]  i_hwdata;
input [2 : 0]           i_hsize;
input                   i_write;
input                   i_read;

/* Output signals */
output [AHB_AW - 1 : 0] o_haddr;
output [AHB_DW - 1 : 0] o_hwdata;
output [2 : 0]          o_hsize;
output reg              o_fifo_full;
output reg              o_fifo_empty;

/* Internal registers */
reg [logSIZE : 0]               r_ptr_r;                                // fifo read pointer
reg [logSIZE : 0]               w_ptr_r;                                // fifo write pointer
reg [AHB_AW - 1 : 0]            fifo_mem_haddr_r [FIFO_SIZE - 1 : 0];   // fifo memory for haddr
reg [AHB_DW - 1 : 0]            fifo_mem_hwdata_r [FIFO_SIZE - 1 : 0];  // fifo memory for hwdata  
reg [2 : 0]                     fifo_mem_hsize_r [FIFO_SIZE - 1 : 0];   // fifo memory for hsize


/* Internal wires */
wire    fifo_we_w;              // fifo write enable
wire    fifo_re_w;              // fifo read enable
wire    fifo_msb_comp_w;        // fifo pointers MSB comparator
wire    pointer_equal_w;        // pointer equal indicator
       


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

/* Fifo control signals */
assign fifo_msb_comp_w = w_ptr_r[logSIZE] ^ r_ptr_r[logSIZE];
assign fifo_we_w = (~o_fifo_full) & i_write;
assign fifo_re_w = (~o_fifo_empty) & i_read;
assign pointer_equal_w = (w_ptr_r[logSIZE - 1 : 0] - r_ptr_r [logSIZE - 1 : 0]) ? 1'b0 : 1'b1;

always @ (*)
begin
        o_fifo_full = fifo_msb_comp_w & pointer_equal_w;
        o_fifo_empty = (~fifo_msb_comp_w) & pointer_equal_w;
end 

/* Fifo memory write */
always @ (posedge clk)
begin
        if(fifo_we_w) begin
                fifo_mem_haddr_r[w_ptr_r[logSIZE - 1 : 0]] <= i_haddr;
                fifo_mem_hwdata_r[w_ptr_r[logSIZE - 1 : 0]] <= i_hwdata;
                fifo_mem_hsize_r[w_ptr_r[logSIZE - 1 : 0]] <= i_hsize;
        end
end

/* Fifo memory read */
assign o_haddr = fifo_mem_haddr_r[r_ptr_r[logSIZE - 1 : 0]];
assign o_hwdata = fifo_mem_hwdata_r[r_ptr_r[logSIZE - 1 : 0]];
assign o_hsize = fifo_mem_hsize_r[r_ptr_r[logSIZE - 1 : 0]];

/* Fifo read pointer */
always @ (posedge clk, negedge rst_n)
begin
        if (rst_n == 1'b0) begin
                r_ptr_r <= 0;
        end else
        begin
                if(fifo_re_w) begin
                        r_ptr_r <= r_ptr_r + 1'b1;
                end
        end
end

/* Fifo write pointer */
always @ (posedge clk, negedge rst_n)
begin
        if (rst_n == 1'b0) begin
                w_ptr_r <= 0;
        end else
        begin
                if(fifo_we_w) begin
                        w_ptr_r <= w_ptr_r + 1'b1;
                end
        end
end
endmodule