//=============================================================================
//     FileName: glb_ctrl.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:34:31
//      History:
//=============================================================================
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
	//input 					sys_ena,
	// comp_sel_cmd shall contain information
	// that indicates computing type and input channnel's
	// number.
	input [31:0] 		comp_cmd,
	input [AW-1:0] 	data_init_addr_in,
	input [AW-1:0]	weight_init_addr_in,
	output 					done,
	
	// When blkend -> 1, data_load -> 0
	input 					blkend,
	// When mapend -> 1, count map number plus 1
	input 					mapend,
	// When result_valid -> 1, data_load -> 1
	input 					result_valid,

	output 					data_load,
	// support DWC only right now
	// noused
	output 					dw_comp,
	output[AW-1:0]	data_init_addr_out,
	output[AW-1:0]	weight_init_addr_out,
	output 					data_init_addr_en
);

localparam int 
DWC = 3'h0,
PWC = 3'h1,
CON = 3'h2,
FC  = 3'h3,
PO  = 3'h4;

reg oclk;
reg data_load_r;
reg chn_cnt_r_c_1;
reg [27:0] chn_cnt_r;

// comp_cmd instruction format
// comp_cmd[31]: init_addr_en
// comp_cmd[30:28]: computation type
// comp_cmd[27:0]: dw channel or pw kernel num
wire [2:0] comp_type = comp_cmd[30:28];
wire [27:0] channal_num = comp_cmd[27:0];
// comp_type
wire dwc_type = comp_cmd == DWC;
wire pwc_type = comp_cmd == PWC;
wire con_type = comp_cmd == CON;
wire fc_type  = comp_cmd == FC ;
wire po_type  = comp_cmd == PO ;
wire chn_cnt_r_c = (chn_cnt_r == channal_num);
wire chn_cnt_r_c_r = chn_cnt_r_c & ~chn_cnt_r_c_1;
wire [27:0] chn_cnt_nxt = mapend ? 
														chn_cnt_r_c_r ? '0
													: chn_cnt_r + 28'b1
								 : chn_cnt_r
								 ;
wire data_load_nxt = comp_cmd[31] ? 1'b1
									 : blkend       ? 1'b0
									 : result_valid ? 1'b1
									 : data_load_r
									 ;

assign done = chn_cnt_r_c_r;
assign data_load = data_load_r | comp_cmd[31];
assign data_init_addr_en = comp_cmd[31];
assign data_init_addr_out = data_init_addr_in;
assign weight_init_addr_out = weight_init_addr_in;
assign dw_comp = dwc_type;

always @(posedge clk) begin
	if (~rst_n) data_load_r <= 0;
	else data_load_r <= data_load_nxt;
end

always @(posedge clk) begin
	chn_cnt_r_c_1 <= chn_cnt_r_c;
end

always @(posedge clk) begin
	if (~rst_n) begin
		chn_cnt_r <= '0;
	end
	else chn_cnt_r <= chn_cnt_nxt;
end

endmodule
