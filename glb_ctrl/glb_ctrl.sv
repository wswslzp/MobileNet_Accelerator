module glb_ctrl#(
	parameter int
	AW = 32,
	KSIZE = 3,
	IW = 32,
	IH = 32,
	//IC = 3, glb_ctrl shall accept 
	//a signal that represent the 
	//input channel num.
	BUFW = 32,
	BUFH = 4
)(
	input 					clk,
	input 					rst_n,

	// clk-gating
	input 					sys_ena,
	// comp_sel_cmd shall contain information
	// that indicates computing type and input channnel's
	// number.
	input [31:0] 		comp_cmd,
	input [AW-1:0] 	data_init_addr_in,
	input [AW-1:0]	weight_init_addr_in,
	output 					done,
	
	input 					blkend,
	input 					mapend,
	input 					result_valid,

	output 					data_load,
	output 					dw_comp,
	output[AW-1:0]	data_init_addr_out,
	output[AW-1:0]	weight_init_addr_out,
	output 					data_init_addr_en
);

wire init_addr_en = comp_cmd[31];
wire dj

assign data_init_addr_out = data_init_addr_in;
assign weight_init_addr_in = weight_init_addr_out;



endmodule
