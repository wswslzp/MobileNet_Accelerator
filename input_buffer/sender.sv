module sender#(
	parameter DW = 32,
	parameter STRIDE = 1,
	parameter POY = 3
)(
	input 					clk,
	input 					rst_n,

	//TODO: What's data_load for?
	//For clearing waddr
	//
	input 					data_load,
	input 					rvalid,
	input 					rlast,
	input [DW-1:0] 	rdata,

	output[DW-1:0] 	wdata,
	output[7:0]			wbank,
	output[7:0]			wrow,
	output[27:0]		wcol
);

localparam 
BUFH = 2*STRIDE,
BUFW = (POX*STRIDE+KSIZE/2),
LM	 = ((STRIDE+1)*POY-STRIDE);

reg [1:0] wbank_r;
reg [27:0] wcol_r;
reg [7:0] row_bias_cnt_r;
reg [7:0] row_base_r;
reg row_bias_cnt_c_1;
reg row_base_c_1;

assign wdata = rdata;
assign wbank = wbank_r;
assign wrow = wrow_r;
assign wcol = wcol_r;

//wire data_en = data_load & rvalid;
wire wcol_c = (wcol_r == BUFW-1);
wire row_bias_cnt_c = (row_bias_cnt_r == STRIDE-1);
wire row_bias_cnt_ff = ~row_bias_cnt_c & row_bias_cnt_c_1;
wire wbank_c = (wbank_r == POY-1);
wire row_base_c = (row_base_r == BUFH);
wire wbank_ff = ~row_base_c & row_base_c_1;

//TODO: DONE?
//when rvalid is down to 0, a row may not be fully
//			writen. wcol_r needs to be kept till a new rvalid come.
always@(posedge clk) begin
	if (~rst_n) wcol_r <= 0;
	else if(~data_load) wcol_r <= 0;
	else if(rvalid) wcol_r <= wcol_c ? 0 : wcol_r + 1;
end

always@(posedge clk) row_base_c_1 <= row_base_c;
always@(posedge clk) row_bias_cnt_c_1 <= row_bias_cnt_c;

always@(posedge clk) begin
	if(~rst_n) wbank_r <= 0;
	else if(~data_load) wbank_r <= 0;
	else if(row_bias_cnt_ff) wbank_r <= wbank_c ? 0 : wbank_r + 1;
end

always@(posedge clk) begin
	if(~rst_n) row_bias_cnt_r <= 0;
	else if(~data_load) row_bias_cnt_r <= 0;
	else if(wcol_c) row_bias_cnt_r <= row_bias_cnt_c ? 0 : row_bias_cnt_r + 1;
end

always@(posedge clk) begin
	if(~rst_n) row_base_r <= 0;
	else if(~data_load) row_base_r <= 0;
	else if(wbank_ff) row_base_r <= row_base_c ? 0 : row_base_r + 1;
end

endmodule
