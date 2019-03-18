module weight_buffer#(
	parameter DW = 32,
	parameter AW = 32,
	parameter KSIZE = 3,
	parameter BURST = 16
)(
	input 					clk,
	input 					rst_n,

	input 					weight_load,
	input [AW-1:0] 	init_addr,
	input 					init_addr_en,

	output[AW-1:0]	araddr,
	output 					arvalid,
	output[3:0] 		arburst,
	input 					arready,
	input [DW-1:0] 	rdata,
	input 					rvalid,

	input 					oready,
	output[DW-1:0] 	oweight
);

cyc_fifo#(
	.DW(DW),
	.DEPTH(KSIZE**2)
)u_cyc_fifo(
	.clk,
	.rst_n,
	.i_data(rdata),
	.i_valid(rvalid),
	.o_ready(oready),
	.o_data(oweight),
	.full(),
	.empty()
);

dwaddr_gen#(
	.AW(AW),
	.BURST(BURST)
)u_dwaddr_gen(
	.clk,
	.rst_n,
	.weight_load,
	.init_addr,
	.init_addr_en,
	.araddr,
	.arvalid,
	.arburst,
	.arready
);

endmodule
