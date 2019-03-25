module addr_gen#(
	parameter 
	AW = 32,
	KSIZE = 3,
	POX = 16,
	POY = 3,
	STRIDE = 2,
	IW = 224,
	IH = 224,
	BURST = 32
)(
	input 					clk,
	input 					rst_n,
	input 					data_load,

	input 					dw_comp,
	// feature map initial address
	input [AW-1:0] 	init_addr,
	input 					init_addr_en,

	// Result refers to a result coming from 
	// accumulation over a convolutional 
	// block.Not a partial sum!
	input 					result_valid,

	output 					blkend,
	output 					mapend,
	input 					rlast,
	output[AW-1:0] 	araddr,
	output 				 	arvalid,
	output[3:0]		 	arburst
);

localparam LM = ((STRIDE+1)*POY-STRIDE);
// RAL must be aligned to BURST, which means that
// POX shall be carefully selected so that RAL is 
// equal to or less than BURST.
// let bufw equal to burst to avoid bug in sender
localparam BUFW = BURST;
localparam RAL = ((POX-1)*STRIDE+KSIZE);
localparam BUFH = STRIDE+1;
localparam BLK_IN_ROW = IW / BUFW;
localparam BLK_ROW_IN_MAP = IH / LM;
localparam BUFW_EQ_BURST = (BUFW == BURST);

reg [7:0] N_cnt;
reg [7:0] lm_cnt;
reg [7:0] blk_cnt;//count blk in a row!
reg [7:0] blkr_cnt;//count row number 
reg [AW-1:0] addr_r;
//current row address in current block
reg [AW-1:0] blk_raddr_r;
//current block prime address
reg [AW-1:0] blk_paddr_r;
reg [1:0] arvalid_state;
reg [2:0] arvalid_cnt;
reg arvalid_r;
reg N_cnt_c_1;
reg lm_cnt_c_1;
reg blk_cnt_c_1;
reg blkr_cnt_c_1;

//wire N_cnt_c = (N_cnt == (BUFW/BURST));
//for now, bufw will never larger than burst!
wire N_cnt_c = 1;
wire lm_cnt_c = (lm_cnt == LM);
wire blk_cnt_c = (blk_cnt == BLK_IN_ROW);
wire blkr_cnt_c = (blkr_cnt == BLK_ROW_IN_MAP);
wire arvalid_cnt_c = (arvalid_cnt == 5);
//Shall the addr_gen manage the feature map prime address
//generation?
//TODO:This address generation got fatal error!
//blkend does not pull up at the same cycle with rlast
wire [AW-1:0] addr_nxt = init_addr_en ? init_addr
												: ~rlast 			 ? addr_r
												: ~N_cnt_c 		 ? addr_r + BURST
												: ~lm_cnt_c 	 ? blk_raddr_r + IW
												//: ~blk_cnt_c   ? blk_paddr_r + BUFW
												: addr_r + 1;// assume that this feature map is not the last one.
wire [AW-1:0] addr_blk_nxt = blk_paddr_r + RAL;
wire blkr_cnt_f = blkr_cnt_c & ~blkr_cnt_c_1;
wire blk_cnt_f = blk_cnt_c & ~blk_cnt_c_1;
wire lm_cnt_f = lm_cnt_c & ~lm_cnt_c_1;
//wire N_cnt_fr = N_cnt_c & ~N_cnt_c_1;
wire N_cnt_ff = ~N_cnt_c & N_cnt_c_1;

assign arburst = $clog2(BURST);
assign araddr = addr_r;
assign arvalid = arvalid_r;
assign blkend = lm_cnt_f;
assign mapend = blkr_cnt_f;

//TODO: the whole logic maybe wrong??? NO, cnts signal
//keep more than one cycles and must overlap the rlast
//BUT the true address cannot be obtained instantly and
//must wait for more than 5 cycles.
always@(posedge clk) begin
	if (~rst_n) N_cnt <= 0;
	else if (rlast) N_cnt <= N_cnt_c ? 0 : N_cnt + 8'b1;
end

always@(posedge clk) N_cnt_c_1 <= N_cnt_c;

always@(posedge clk) begin
	if (~rst_n) lm_cnt <= 0;
	else if(result_valid) lm_cnt <= 0;
	else if (N_cnt_ff || (BUFW_EQ_BURST & rlast)) lm_cnt <= lm_cnt_c ? 0 : lm_cnt + 8'b1;
end

always@(posedge clk) lm_cnt_c_1 <= lm_cnt_c;

always@(posedge clk) begin
	if (~rst_n) blk_cnt <= 0;
	else if (lm_cnt_f) blk_cnt <= blk_cnt_c ? 0 : blk_cnt + 8'b1;
end

always@(posedge clk) blk_cnt_c_1 <= blk_cnt_c;

always@(posedge clk) begin
	if (~rst_n) blkr_cnt <= 0;
	else if (blk_cnt_f) blkr_cnt <= blkr_cnt_c ? 0 : blkr_cnt + 8'b1;
end

always@(posedge clk) blkr_cnt_c_1 <= blkr_cnt_c;

always@(posedge clk) begin
	if (~rst_n) blk_raddr_r <= 0;
	else if (init_addr_en) blk_raddr_r <= init_addr;
	else if (result_valid) blk_raddr_r <= addr_blk_nxt;
	//control the time of change
	else if (N_cnt_c & rlast) blk_raddr_r <= addr_nxt;
end

always@(posedge clk) begin
	if (~rst_n) blk_paddr_r <= 0;
	else if (init_addr_en) blk_paddr_r <= init_addr;
	else if (result_valid) blk_paddr_r <= addr_blk_nxt;
end

//redesign the code 
always@(posedge clk) begin
	if (~rst_n) addr_r <= 0;
	else if (blkend) addr_r <= addr_blk_nxt;
	else addr_r <= addr_nxt;
end

//TODO: DONE
//when to pull up arvalid?
//Either 5cycles after rlast,or right 
//after rlast? DONE.
//TODO:
//what is data_load for?
//data_load calls for loading a block?
//i dont know yet.
always@(posedge clk) begin
	if (~rst_n) arvalid_cnt <= 0;
	else if(rlast) arvalid_cnt <= 3'h1;
	else if(arvalid_cnt != 0) arvalid_cnt <= arvalid_cnt_c ? 3'h0 : arvalid_cnt + 3'h1;
end

always@(posedge clk) begin
	if (~rst_n) arvalid_state <= 2'h0;
	else if(rlast) arvalid_state <= 2'h1;
	else if(blkend) arvalid_state <= 2'h2;
	else if(mapend) arvalid_state <= 2'h3;
	else if(arvalid) arvalid_state <= 2'h0;
end

//TODO: DONE
//FATAL ERROR:
//arvalid_cnt_c does not pull up at the same 
//cycle with result_valid.
always@(posedge clk) begin
	if (~rst_n) arvalid_r <= 0;
	else if(arvalid_r) arvalid_r <= 0;
	else if(init_addr_en) arvalid_r <= 1;
	else if(result_valid) arvalid_r <= 1;
	else if (arvalid_cnt_c) begin
		case(arvalid_state) 
			2'h0: arvalid_r <= 0;
			2'h1: arvalid_r <= 1;
			//2'h2: //DO NOTHING
			//2'h2: if(result_valid) arvalid_r <= 1;
			//			else arvalid_r <= 0;
			2'h3: arvalid_r <= 0;
		endcase
	end
end

endmodule
