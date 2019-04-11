//=============================================================================
//     FileName: data_path_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:34:42
//      History:
//=============================================================================
`timescale 1ns/1ns
module data_path_tb;

parameter DW = 32, AW = 32,
	IW = 32, IH = 32, IC = 3, KSIZE = 3,
	POX = 15, POY = 3, STRIDE = 2,
	BURST = 32, BUFW = BURST;

bit clk = 0;
logic rst_n;
logic data_load, dw_comp, data_init_addr_en,  blkend, mapend, result_valid[POY][POX];
logic [AW-1:0] data_init_addr, weight_init_addr;
logic [DW-1:0] result[POY][POX];

always #50 clk = ~clk;

axi_bus_if#(DW, AW) bus1(clk);
axi_bus_if#(DW, AW) bus2(clk);

sdram_sim #(
	.DW(DW),
	.DP(IW*IH*IC),
	.AW(AW)
)u_sdram_sim_1(
	.dram_if(bus1)
);

sdram_sim #(
	.DW(DW),
	.DP(IW*IH*IC),
	.AW(AW)
)u_sdram_sim_2(
	.dram_if(bus2)
);

data_path#(
	.DW(DW),
	.AW(AW),
	.IW(IW),
	.IH(IH),
	.KSIZE(KSIZE),
	.POX(POX),
	.POY(POY),
	.STRIDE(STRIDE),
	.BURST(BURST)
)u_data_path(
	.*,
	.rdata_0(bus1.rdata),
	.rlast_0(bus1.rlast),
	.rvalid_0(bus1.rvalid),
	.arready_0(bus1.arready),
	.araddr_0(bus1.araddr),
	.arburst_0(bus1.arburst),
	.arvalid_0(bus1.arvalid),
	.rdata_1(bus2.rdata),
	.rlast_1(bus2.rlast),
	.rvalid_1(bus2.rvalid),
	.arready_1(bus2.arready),
	.araddr_1(bus2.araddr),
	.arburst_1(bus2.arburst),
	.arvalid_1(bus2.arvalid)
);

data_path_test#(
	.AW(AW),
	.IW(IW),
	.IH(IH),
	.BUFW(BURST),
	.KSIZE(KSIZE),
	.BUFH(2*STRIDE)
) u_test(.*, 
				 .result_valid(result_valid[0][0])
			 );

initial begin
	rst_n = 0;
	repeat(3) @(posedge clk);
	rst_n = 1;
	// simulate behavior of glb_ctrl
end
	

endmodule
