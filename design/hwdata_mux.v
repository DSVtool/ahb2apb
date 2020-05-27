
module hwdata_mux #(
        parameter AHB_DW = 32,
        parameter APB_DW = 8,
        parameter RATIO = 4,
        parameter logRATIO = 2
)
(
        in,
        sel,
        out
);

input [AHB_DW - 1 : 0]          in;
input [logRATIO - 1 : 0]        sel;
output [APB_DW - 1 : 0]         out;

wire [APB_DW - 1 : 0] in_partial [RATIO - 1 : 0];

genvar i;
generate
        for (i = 0; i < RATIO; i = i + 1) begin : mux_inputs
                assign in_partial[i] = in [(i + 1)*APB_DW - 1 : i*APB_DW];
        end
endgenerate

assign out = in_partial[sel];

endmodule