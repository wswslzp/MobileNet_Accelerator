module addr_gen#(
	parameter DW = 32,
	AW = 32,
	BUFW = 32,
	STRIDE = 2,
	BURST = 32
)(
	input 					clk,
	input 					rst_n,
	input 					dataload,

	input 					dw_comp,
	input [AW-1:0] 	init_addr,
	input 					init_addr_en,

	output 					blkend,
	output 					mapend,
	input 					rlast,
	output[AW-1:0] 	araddr,
	output 				 	arvalid,
	output[3:0]		 	arburst
);

reg [7:0] N_cnt;
reg [7:0] lm_cnt;
reg [AW-1:0] addr_r;

wire N_cnt_c = (N_cnt == (BUFW/BURST));
wire lm_cnt_c = (lm_cnt == STRIDE+1);

//blkend shall trigger after 6 cycles of weight load signal
//assign bl
assign arburst = $clog2(BURST);

always@(posedge clk) begin
	if (~rst_n) N_cnt <= 0;
	else if (rlast) N_cnt <= N_cnt_c ? 0 : N_cnt + 8'b1;
end

always@(posedge clk) begin
	if (~rst_n) lm_cnt <= 0;
	else if (N_cnt_c) lm_cnt <= lm_cnt_c ? 0 : lm_cnt + 8'b1;
end

always @(posedge clk) begin
	if (~rst_n) addr_r <= 0;
	else if (

endmodule
