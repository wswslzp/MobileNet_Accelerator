//=============================================================================
//     FileName: data_router_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:33:46
//      History:
//=============================================================================
`timescale 1ns/1ns
module data_router_tb;

parameter DW = 32,
	POY = 3,
	POX = 16,
	BUFW = 48,
	KSIZE = 4,
	STRIDE = 1;
parameter BUFH = STRIDE+1;

logic clk, rst_n, blkend, dwpe_ena;
logic [1:0] rpsel;
logic [7:0] bank, row;
logic [27:0] col;
logic [DW-1:0] data[POY][BUFW], 
	dwpixel_array[POY][POX],
	pwpixel_array[POY];

event dwpe_done;

always @(negedge dwpe_ena) ->dwpe_done;

always #50 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	repeat(5) @(posedge clk);
	rst_n = 1;

	repeat(1000) @(posedge clk);
	$stop;
end

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
	.BUFH(BUFH),
	.KSIZE(KSIZE),
	.STRIDE(STRIDE))
	u_data_router_if_sim(
		.*);
	
endmodule
