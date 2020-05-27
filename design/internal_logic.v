
module internal_logic #(
        parameter AHB_AW = 32,
        parameter AHB_DW = 32
)
(
        hclk,
        rst_n,
        i_haddr_read,
        i_haddr_write,
        i_hsize_read,
        i_hsize_write,
        i_hready,
        o_haddr,
        o_hsize,
        i_fifo_empty,
        i_read_transfer,
        o_start_transfer
        
);

input hclk;
input rst_n;

input [AHB_AW - 1 : 0]  i_haddr_read;
input [AHB_AW - 1 : 0]  i_haddr_write;
input [2:0]             i_hsize_read;
input [2:0]             i_hsize_write;
input                   i_hready;
output [AHB_AW - 1 : 0] o_haddr;
output [2:0]            o_hsize;

input                   i_fifo_empty;
input                   i_read_transfer;
output                  o_start_transfer;

/* Internal wires */
wire                    w_start_read_transfer;
wire                    w_start_write_transfer;
wire                    w_fifo_not_empty_detector;
wire                    w_start_read_transfer_detector;
wire                    w_start_write_transfer_detector;

/* Internal registers */
reg                     r_hready_delay;

/* HADDR and HSIZE mux */
assign o_haddr = i_fifo_empty ? i_haddr_read : i_haddr_write;
assign o_hsize = i_fifo_empty ? i_hsize_read : i_hsize_write;



/* Assigning wires value */
assign w_start_read_transfer = i_read_transfer & i_fifo_empty;
assign w_start_write_transfer = (r_hready_delay & (~i_fifo_empty)) | w_fifo_not_empty_detector;

/* Assigning registers value */
always @ (posedge hclk)
begin
        r_hready_delay <= i_hready;
end

/* Assigning outputs */
assign o_start_transfer = w_start_read_transfer_detector | w_start_write_transfer_detector;  

/* START READ TRANSFER */
positive_edge_detector START_READ_TRANSFER(
        .clk(hclk),
        .in(w_start_read_transfer),
        .out(w_start_read_transfer_detector)
);

/* START WRITE TRANSFER */
positive_edge_detector START_WRITE_TRANSFER(
        .clk(hclk),
        .in(w_start_write_transfer),
        .out(w_start_write_transfer_detector)
);

/* FIFO NOT EMPTY EDGE DETECTOR */
positive_edge_detector FIFO_NOT_EMPTY_DETECTOR(
        .clk(hclk),
        .in(~i_fifo_empty),
        .out(w_fifo_not_empty_detector)
);

endmodule



 