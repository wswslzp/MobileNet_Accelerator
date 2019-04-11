//=============================================================================
//     FileName: axi_bus_sim.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:37:17
//      History:
//=============================================================================
module axi_bus_sim#(
	parameter DW = 32,
	parameter AW = 32
)(
	input 					clk,
	input 					rst_n,
	
	input [AW-1:0]	araddr,
	input 					arvalid,
	input [3:0] 		arburst,
	output 					arready,
	output[DW-1:0]	rdata,
	output 					rlast,
	output 					rvalid
);

reg [DW-1:0] mem[1024];//addr width=10
reg [9:0] addr_r;
reg [13:0] burst_r;
reg ovld;
reg [DW-1:0] rdata_r;
reg rvalid_r;
reg [13:0] burst_cnt;
reg arready_r;

wire [9:0] addr = araddr[9:0];
wire burst_cnt_f = (burst_cnt == burst_r);

assign rlast = burst_cnt_f;
assign arready = arready_r;
assign rdata = rdata_r;
assign rvalid = rvalid_r & ovld;

initial begin
	for(int i = 0; i < 1024; i++)
		mem[i] = i;
end

always @(posedge clk) begin
	if (~rst_n) begin 
		addr_r <= 0;
		burst_r <= 0;
	end
	else if (arvalid) begin
		addr_r <= addr;
		//burst_r <= 2**arburst;
		burst_r <= 1 << arburst;
	end
	else;
end

always @(posedge clk) begin
	if (~rst_n) begin
		ovld <= 0;
		arready_r <= 1;
	end
	else if (arvalid) begin
		ovld <= 1;
		arready_r <= 0;
	end else if (burst_cnt_f) begin
		ovld <= 0;
		arready_r <= 1;
	end
end

always @(posedge clk) begin
	if (~rst_n) begin
		rdata_r <= 0;
		rvalid_r <= 0;
		burst_cnt <= 0;
	end
	else if (ovld) begin
		rdata_r <= mem[addr_r + burst_cnt];
		rvalid_r <= 1;
		burst_cnt <= burst_cnt_f ? 0 : burst_cnt + 1;
	end
	else rvalid_r <= 0;
end

endmodule

