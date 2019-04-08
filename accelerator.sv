module accelerator#(
	parameter 
	DW = 32,
	AW = 32,
	POX = 15,
	POY = 3,
	KSIZE = 3,
	STRIDE = 2,
	BURST = 32,
	IW = 224,
	IH = 224
) (
	input 					clk,
	input 					rst_n,

	//from BUS0
	input [DW-1:0] 	rdata_0,
	input 					rvalid_0,
	input 					rlast_0,
	output[AW-1:0]	araddr_0,
	output[3:0]			arburst_0,
	output 					arvalid_0,
	input 					arready_0,
	//from BUS1
	input [DW-1:0] 	rdata_1,
	input 					rvalid_1,
	input 					rlast_1,
	output[AW-1:0]	araddr_1,
	output[3:0]			arburst_1,
	output 					arvalid_1,
	input 					arready_1,

	//from system
	input [31:0]		comp_cmd,
	input [AW-1:0]	data_init_addr_in,
	input [AW-1:0]	weight_init_addr_in,
	output 					done,

	//to output buffer
	//accelerator doesnt contain output buffer
	output[DW-1:0]	result[POY][POX],
	output 					result_valid[POY][POX]
);

localparam BUFW = BURST;
localparam BUFH = 2*STRIDE;

wire [AW-1:0] data_init_addr, weight_init_addr;
wire data_load, dw_comp, data_init_addr_en;
wire blkend, mapend;
//wire result_valid[POY][POX];
wire g_result_valid = result_valid[0][0];

glb_ctrl #(
	.AW(AW),
	.KSIZE(KSIZE),
	.IW(IW),
	.IH(IH),
	.BUFH(BUFH),
	.BUFW(BUFW)
)u_glb_ctrl(
	.*,
	//.data_init_addr_in(data_init_addr),
	//.weight_init_addr_in(weight_init_addr),
	.data_init_addr_out(data_init_addr),
	.weight_init_addr_out(weight_init_addr),
	.result_valid(g_result_valid)
);

data_path #(
	.AW(AW),
	.DW(DW),
	.KSIZE(KSIZE),
	.POX(POX),
	.POY(POY),
	.STRIDE(STRIDE),
	.IW(IW),
	.IH(IH),
	.BURST(BURST)
	//.BUFW(BUFW)
)u_data_path(
	.*,
	.result_valid
);

endmodule
