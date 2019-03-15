`timescale 1ns/1ns
module data_router_tb;

parameter DW = 32,
	POY = 3,
	POX = 16,
	BUFW = 32,
	KSIZE = 3,
	STRIDE = 1;

logic clk, rst_n, blkend, dwpe_ena;
logic [1:0] bank, row, rpsel;
logic [27:0] col;
logic [DW-1:0] data[POY][BUFW], 
	dwpixel_array[POY][POX],
	pwpixel_array[POY];

always #50 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	repeat(5) @(posedge clk);
	rst_n = 1;

	repeat(100) @(posedge clk);
	$stop;
end

//TODO: dwpixel_array[2] is 'x, check it!!!
//TODO: FSM seems to be right but dwpixel all wrong!!
data_router#(
	.DW(DW),
	.POX(POX),
	.POY(POY),
	.BUFW(BUFW),
	.KSIZE(KSIZE),
	.STRIDE(STRIDE))
	u_data_router(
		.clk,
		.rst_n,
		.dw_comp(),
		.blkend,
		.data,
		.rpsel,
		.bank,
		.row,
		.col,
		.dwpixel_array,
		.dwpe_ena,
		.pwpixel_array);

data_router_if_sim#(
	.DW(DW),
	.POX(POX),
	.POY(POY),
	.BUFW(BUFW),
	.KSIZE(KSIZE),
	.STRIDE(STRIDE))
	u_data_router_if_sim(
		.*);
	
endmodule
