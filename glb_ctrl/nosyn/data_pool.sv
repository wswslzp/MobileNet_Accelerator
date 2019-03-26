module sdram_sim #(
	parameter 
	DW = 32,
	DP = 32*32,
	AW = 32
)(
	axi_bus_if.dram dram_if//,
	//input rst_n
);

bit [DW-1:0] mem[DP];
int burst_max;

initial begin
	foreach(mem[i]) mem[i] = i;
	dram_if.dram_cb.arready <= 1;
	dram_if.dram_cb.rvalid <= 0;
	dram_if.dram_cb.rdata <= 0;
	dram_if.dram_cb.rlast <= 0;
end

always@(dram_if.dram_cb) begin
	if (dram_if.dram_cb.arvalid) begin
		// response time
		repeat(1) @(dram_if.dram_cb);
		burst_max = 2**dram_if.dram_cb.arburst;
		for(int i = 0; i < burst_max; i++) begin
			dram_if.dram_cb.rvalid <= 1;
			dram_if.dram_cb.rdata <= mem[dram_if.dram_cb.araddr+i];
			dram_if.dram_cb.arready <= 0;
			if (i == burst_max-1) 
				dram_if.dram_cb.rlast <= 1;
			@(dram_if.dram_cb);
			dram_if.dram_cb.rlast <= 0;
		end
		dram_if.dram_cb.rvalid <= 0;
	end
end

endmodule
