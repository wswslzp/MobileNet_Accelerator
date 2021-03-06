//=============================================================================
//     FileName: weight_buffer_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:37:40
//      History:
//=============================================================================
`timescale 1ns/1ns
module weight_buffer_tb;

parameter DW = 32, AW = 32, KSIZE = 3, BURST = 32;

logic clk, rst_n, weight_load, init_addr_en, arvalid, arready, rvalid,
	dw_ready, dw_comp, rlast;
logic [AW-1:0] init_addr, araddr;
logic [DW-1:0] rdata, dw_out;
logic [3:0] arburst;

weight_buffer#(
	.DW(DW),
	.AW(AW),
	.KSIZE(KSIZE),
	.BURST(BURST)
)u_weight_buffer(
	.*
);

axi_bus_sim#(
	.DW(DW),
	.AW(AW)
)u_axi_bus_sim(
	.*
);

always #50 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	weight_load = 0;
	init_addr_en = 0;
	init_addr = 90;
	dw_ready = 0;
	repeat(3) @(posedge clk);
	rst_n = 1;
	dw_ready = 1;
	@(posedge clk);

	for(int i = 0; i < 10; i++) begin
		//@(posedge clk);
		if (i == 0) begin
			weight_load = 1;
			init_addr_en = 1;
			init_addr = 90;
		end
		else begin
			weight_load = 1;
			init_addr_en = 0;
			init_addr = 0;
		end
		@(posedge clk);
		weight_load = 0;
		init_addr_en = 0;
		repeat(260) @(posedge clk);
	end
	$stop;
end

endmodule
