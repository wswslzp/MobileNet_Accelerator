//=============================================================================
//     FileName: input_buffer.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:35:24
//      History:
//=============================================================================
module input_buffer#(
	parameter 
	DW = 32,
	AW = 32,
	KSIZE = 3,
	POX = 16,
	POY = 3,
	STRIDE = 2,
	IW = 224,
	IH = 224,
	BURST = 32,
	BUFW = BURST
)(
	input 					clk, 
	input 					rst_n, 
	
	input [DW-1:0] 	rdata,
	input 					rvalid,
	input 					rlast,

	input 					arready,
	output[AW-1:0]  araddr,
	output 					arvalid,
	output[3:0] 		arburst,

	output 					weight_load,
	input 					result_valid,

	input 					data_load,
	input 					dw_comp,//unused
	input[AW-1:0]  	init_addr,
	input 					init_addr_en,
	output 					blkend,
	output  				mapend,

	output[DW-1:0]	odata[POY][BUFW],
	input [1:0] 		rpsel,
	input [7:0]  		rbank,
	input [7:0] 		rrow,
	input [27:0]		rcol
);

wire wvalid;
wire [DW-1:0] wdata;
wire [7:0] wbank, wrow;
wire [27:0] wcol;

data_router_if_sim#(
	.DW(DW),
	.POY(POY),
	.POX(POX),
	.KSIZE(KSIZE),
	.STRIDE(STRIDE),
	.BUFW(BUFW)
)u_data_router_if_sim(
	.*,
  .rdata(odata));

addr_gen#(
	.AW(AW),
	.KSIZE(KSIZE),
	.POX(POX),
	.POY(POY),
	.STRIDE(STRIDE),
	.IW(IW),
	.IH(IH),
	.BURST(BURST)
)u_addr_gen(
	.*);

sender#(
	.DW(DW),
	.STRIDE(STRIDE),
	.KSIZE(KSIZE),
	.BURST(BURST),
	.POX(POX),
	.POY(POY)
)u_sender(
	.*);

endmodule
