`timescale 1ns/1ns
module accelerator_tb #(
	parameter
	DW = 32,
	AW = 32,
	POX = 15,
	POY = 3,
	KSIZE = 3,
	STRIDE = 2,
	BURST = 32,
	IW = 64,
	IH = 64,
	IC = 64
) (
	//noused
);

bit clk, rst_n;
logic [31:0] comp_cmd;
logic [AW-1:0] data_init_addr_in, weight_init_addr_in;
logic done, result_valid[POY][POX];
logic [DW-1:0] result[POY][POX];

always #50 clk = ~clk;

axi_bus_if#(DW, AW) bus1(clk);
axi_bus_if#(DW, AW) bus2(clk);

accelerator_test#(AW, IC) u_acc_test
(
	.*
);

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

accelerator #(
	.DW(DW),
	.AW(AW),
	.POX(POX),
	.POY(POY),
	.KSIZE(KSIZE),
	.STRIDE(STRIDE),
	.BURST(BURST),
	.IW(IW),
	.IH(IH)
)u_accelerator(
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

initial begin
	clk = 0;
	rst_n = 0;
	repeat(2) @(posedge clk);
	rst_n = 1;
end

endmodule
