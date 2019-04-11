//=============================================================================
//     FileName: weight_buffer.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:37:36
//      History:
//=============================================================================
module weight_buffer#(
	parameter DW = 32,
	parameter AW = 32,
	parameter KSIZE = 3,
	parameter BURST = 16
)(
	input 					clk,
	input 					rst_n,

	input 					dw_comp,
	input 					weight_load,
	input [AW-1:0] 	init_addr,
	input 					init_addr_en,

	output[AW-1:0]	araddr,
	output 					arvalid,
	output[3:0] 		arburst,
	input 					arready,
	input [DW-1:0] 	rdata,
	input 					rvalid,
	input 					rlast,

	input 					dw_ready,
	output[DW-1:0] 	dw_out
);

reg [7:0] ivld_cnt;

wire ivld_cnt_f = (ivld_cnt == KSIZE**2);
wire ivld_mask = (ivld_cnt < KSIZE**2);
wire i_valid = rvalid & ivld_mask;

always @(posedge clk) begin
	if (~rst_n) ivld_cnt <= 0;
	else if (rvalid) ivld_cnt <= ivld_cnt_f ? ivld_cnt : ivld_cnt + 1;
	else ivld_cnt <= 0;
end

cyc_fifo#(
	.DW(DW),
	.DEPTH(KSIZE**2)
)u_cyc_fifo(
	.clk,
	.rst_n,
	.i_data(rdata),
	.i_valid,
	.weight_load,
	.o_ready(dw_ready),
	.o_data(dw_out),
	.full(),
	.empty()
);

dwaddr_gen#(
	.AW(AW),
	.KSIZE(KSIZE),
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
