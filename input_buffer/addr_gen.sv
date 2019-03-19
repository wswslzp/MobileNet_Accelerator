module addr_gen#(
	parameter DW = 32,
	AW = 32
)(
	input clk,
	input rst_n,
	input dataload,

	input dw_comp,
	input [AW-1:0] init_addr,
	input init_addr_en,

	output blkend,
	output mapend,
	output[AW-1:0] araddr,
	output 				 arvalid,
	output[3:0]		 arburst
);



endmodule
