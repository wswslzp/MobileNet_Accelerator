//=============================================================================
//     FileName: data_path.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:34:25
//      History:
//=============================================================================
module data_path#(
	parameter 
	DW = 32,
	AW = 32,
	KSIZE=3,
	POX = 15,
	POY = 3,
	STRIDE=2,
	IW = 224,
	IH = 224,
	BURST = 32
	//BUFW = BURST
)(
	input 					clk,
	input 					rst_n,

	//from dram0-data
	input [DW-1:0] 	rdata_0,
	input 					rlast_0,
	input 					rvalid_0,
	input 					arready_0,
	output[AW-1:0]	araddr_0,
	output[3:0]			arburst_0,
	output 					arvalid_0,

	//from dram1-weight
	input [DW-1:0] 	rdata_1,
	input 					rlast_1,
	input 					rvalid_1,
	input 					arready_1,
	output[AW-1:0]	araddr_1,
	output[3:0]			arburst_1,
	output 					arvalid_1,

	//from glb_ctrl
	input 					data_load,
	//input 					weight_load,
	input 			dw_comp,//unused
	input [AW-1:0]	data_init_addr,
	input [AW-1:0]	weight_init_addr,
	input 					data_init_addr_en,
	//input 					weight_init_addr_en,
	output 					blkend,
	output 					mapend,

	//from pe to output buffer
	output[DW-1:0]	result[POY][POX],
	output 					result_valid[POY][POX]
);

localparam BUFW = BURST;

wire [DW-1:0] odata[POY][BUFW];
wire [1:0] rpsel;
wire [7:0] rbank, rrow;
wire [27:0] rcol;
wire dwpe_ena, weight_load;
wire [DW-1:0] dw_out;
wire [DW-1:0] dwpixel_array[POY][POX];

input_buffer#(
	.DW(DW),
	.AW(AW),
	.KSIZE(KSIZE),
	.POX(POX),
	.POY(POY),
	.STRIDE(STRIDE),
	.IW(IW),
	.IH(IH),
	.BURST(BURST)
)u_input_buffer(
	.*,
	.result_valid(result_valid[0][0]),
	.rdata(rdata_0),
	.rvalid(rvalid_0),
	.rlast(rlast_0),
	.arready(arready_0),
	.araddr(araddr_0),
	.arvalid(arvalid_0),
	.arburst(arburst_0),
	.init_addr(data_init_addr),
	.init_addr_en(data_init_addr_en)
);

//dw_ready timing shall be tunning!!
weight_buffer#(
	.DW(DW),
	.AW(AW),
	.KSIZE(KSIZE),
	.BURST(BURST)
)u_weight_buffer(
	.*,
	.dw_ready(1'b1), //TODO
	.rdata(rdata_1),
	.rvalid(rvalid_1),
	.rlast(rlast_1),
	.arready(arready_1),
	.araddr(araddr_1),
	.arvalid(arvalid_1),
	.arburst(arburst_1),
	.init_addr(weight_init_addr),
	.init_addr_en(weight_load) // Weight load substitus weight init addr en????
);

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
	.data(odata),
	.rpsel,
	.bank(rbank),
	.row(rrow),
	.col(rcol),
	.dwpixel_array,
	.dwpe_ena,
	.pwpixel_array()
);

dwpe_array#(
	.DW(DW),
	.POX(POX),
	.POY(POY)
)u_dwpe_array(
	.pixel_array(dwpixel_array),
	.weight(dw_out),
	.result,
	.clk,
	.rst_n,
	.result_valid,
	.dwpe_ena
);

endmodule
