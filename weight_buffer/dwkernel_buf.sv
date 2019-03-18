module dwkernel_buf#(
	parameter DW = 32,
	// no pof
	KSIZE = 3
)(
	input 					clk,
	input 					rst_n,

	// needless signal
	input 					dw_comp,
	input [DW-1:0] 	rdata,
	input 					rvalid,
	input 					blkend,
	output[DW-1:0]	o_pe_weight
);

reg [DW-1:0] dwmem[KSIZE**2];
reg shift_start;

wire rdata_en = dw_comp & rvalid;
wire dwmem_in_data = dwmem[0];

assign o_pe_weight = dwmem[0];

always@(posedge clk) begin
	j

endmodule
