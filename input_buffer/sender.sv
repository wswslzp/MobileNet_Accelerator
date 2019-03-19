module sender#(
	parameter DW = 32,
	parameter STRIDE = 1,
	parameter POY = 3
)(
	input clk,
	input rst_n,

	input dataload,
	input rvalid,
	input [DW-1:0] rdata,

	output[DW-1:0] o_buf_data[POY]
);



endmodule
