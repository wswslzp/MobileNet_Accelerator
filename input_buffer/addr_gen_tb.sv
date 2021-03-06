//=============================================================================
//     FileName: addr_gen_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:35:09
//      History:
//=============================================================================
`timescale 1ns/1ns
module addr_gen_tb;

//BUFW = 16*1+1 = 17. BUFW/BURST=1
//a burst transfer a buffer row!!
parameter AW = 32, KSIZE = 3, POX = 15, POY = 3, STRIDE = 2, IW = 224, IH = 224, BURST = 32;

logic clk, rst_n, data_load, dw_comp,init_addr_en, result_valid, blkend, mapend, rlast, arvalid;
logic [AW-1:0] init_addr, araddr;
logic [3:0] arburst;

addr_gen #(
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

axi_bus_sim #(
	.AW(AW),
	.DW(32)
)u_axi_bus_sim(
	.*,
	.rdata(),
	.rvalid(),
	.arready()
);

always #50 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
//	rlast = 0;
	result_valid = 0;
	repeat(3) @(posedge clk);
	rst_n = 1;
	repeat(5) @(posedge clk);
	init_addr = 32'd0;
	init_addr_en = 1;
	@(posedge clk) init_addr_en = 0;
	@(posedge blkend);
	repeat(KSIZE*3+4) @(posedge clk);
	result_valid = 1;
	@(posedge clk);
	result_valid = 0;
	repeat(1000) @(posedge clk);
	$stop;
end

//always @(posedge clk) begin
//	if(arvalid) begin 
//		$display("araddr = %d", araddr); 
//		repeat(BURST) @(posedge clk);
//		rlast = 1;
//		@(posedge clk) rlast = 0;
//	end
//end
//

endmodule
