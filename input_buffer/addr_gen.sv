module addr_gen#(
	parameter DW = 32,
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

	output 					blkend,
	output 					mapend,
	input 					rlast,
	output[AW-1:0] 	araddr,
	output 				 	arvalid,
	output[3:0]		 	arburst
);

localparam LM = ((STRIDE+1)*POY-STRIDE);
localparam BUFW = (POX*STRIDE+KSIZE/2);
localparam BUFH = STRIDE+1;
localparam BLK_IN_ROW = IW / BUFW;
localparam BLK_ROW_IN_MAP = IH / LM;

reg [7:0] N_cnt;
reg [7:0] lm_cnt;
reg [7:0] blk_cnt;//count blk in a row!
reg [7:0] blkr_cnt;//count row number 
reg [AW-1:0] addr_r;
//current row address in current block
reg [AW-1:0] blk_raddr_r;
//current block prime address
reg [AW-1:0] blk_paddr_r;

wire N_cnt_c = (N_cnt == (BUFW/BURST));
wire lm_cnt_c = (lm_cnt == LM);
wire blk_cnt_c = (blk_cnt == BLK_IN_ROW);
wire blkr_cnt_c = (blkr_cnt == BLK_ROW_IN_MAP);
//Shall the addr_gen manage the feature map prime address
//generation?
wire addr_nxt = init_addr_en ? init_addr
							: ~rlast 			 ? addr_r
              : ~N_cnt_c 		 ? addr_r + BURST
							: ~lm_cnt_c 	 ? blk_raddr_r + IW
							: ~blk_cnt_c   ? blk_paddr_r + BUFW
							//: ~blkr_cnt_c  ? addr_r + 1
							: addr_r + 1;// assume that this feature map is not the last one.

//assign bl
assign arburst = $clog2(BURST);
assign araddr = addr_r;

//TODO: the whole logic maybe wrong??? NO, cnts signal
//keep more than one cycles and must overlap the rlast
//BUT the true address cannot be obtained instantly and
//must wait for more than 5 cycles.
always@(posedge clk) begin
	if (~rst_n) N_cnt <= 0;
	else if (rlast) N_cnt <= N_cnt_c ? 0 : N_cnt + 8'b1;
end

always@(posedge clk) begin
	if (~rst_n) lm_cnt <= 0;
	else if (N_cnt_c) lm_cnt <= lm_cnt_c ? 0 : lm_cnt + 8'b1;
end

always @(posedge clk) begin
	if (~rst_n) blk_cnt <= 0;
	else if (lm_cnt_c) blk_cnt <= blk_cnt_c ? 0 : blk_cnt + 8'b1;
end

always @(posedge clk) begin
	if (~rst_n) blkr_cnt <= 0;
	else if (blk_cnt_c) blkr_cnt <= blkr_cnt_c ? 0 : blkr_cnt + 8'b1;
end

always @(posedge clk) begin
	if (~rst_n) blk_raddr_r <= 0;
	else if (init_addr_en) blk_raddr_r <= init_addr;
	else if (N_cnt_c) blk_raddr_r <= addr_nxt;
end

always @(posedge clk) begin
	if (~rst_n) blk_paddr_r <= 0;
	else if (init_addr_en) blk_paddr_r <= init_addr;
	else if (lm_cnt_c) blk_paddr_r <= addr_nxt;
end

always @(posedge clk) begin
	if (~rst_n) addr_r <= 0;
	else addr_r <= addr_nxt;
end

//TODO: when to pull up arvalid?
//			what is data_load for?


endmodule
