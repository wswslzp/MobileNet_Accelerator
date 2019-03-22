module data_router_if_sim#(
	parameter DW = 32,
	parameter POY = 3,
	parameter POX = 16,
	parameter BUFW = 32,
	parameter KSIZE = 3,
	parameter STRIDE = 1
)(
	input 						clk,
	input 						rst_n,


	// to data router 
	output [DW-1:0] 	odata[POY][BUFW],
	input [1:0]				rpsel,
	input [1:0]				bank,
	input [1:0]				row,
	input [27:0]			col

	input [DW-1:0]		idata[POY][BUFW],
);




endmodule
