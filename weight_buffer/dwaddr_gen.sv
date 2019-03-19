module dwaddr_gen#(
	parameter AW = 32,
	parameter BURST = 16
)(
	input 					clk,
	input 					rst_n,

	// weight_load signal shall keep
	// 1 cycle and generate initaddr_en
	// at the same time.
	input 					weight_load,
	input [AW-1:0] 	init_addr,
	input 					init_addr_en,

	output[AW-1:0]	araddr,
	output 					arvalid,
	output[3:0]			arburst,
	input 					arready
);

reg [AW-1:0] addr;
reg arvalid_r;

wire load_init_addr = weight_load & init_addr_en; 
wire load_next_addr = weight_load & ~init_addr_en;
wire [AW-1:0] addr_nxt = addr + BURST;

assign araddr =  addr ;
assign arvalid =  arvalid_r ;
assign arburst =  $clog2(BURST) ;

always@(posedge clk) begin
	if (~rst_n) begin
		addr <= 0;
		arvalid_r <= 1'b0;
	end
	else if(load_init_addr) begin
		addr <= init_addr;
		arvalid_r <= 1'b1;
	end
	else if(load_next_addr) begin
		addr <= addr_nxt;
		arvalid_r <= 1'b1;
	end
	else arvalid_r <= 0;
end

endmodule
