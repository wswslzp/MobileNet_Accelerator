//=============================================================================
//     FileName: sender_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:36:06
//      History:
//=============================================================================
`timescale 1ns/1ns
module sender_tb;

// parameter shall carefully select so as to align BUFW to BURST.
// 
parameter DW = 32, STRIDE = 2, POY = 4, POX = 15, KSIZE = 3;
parameter BURST = 32;

logic clk, rst_n, data_load, rvalid;
logic [DW-1:0] rdata, wdata;
logic [7:0] wbank, wrow;
logic [27:0] wcol;
int data[1024];

event data_gen_done;

sender #(
	.DW(DW),
	.STRIDE(STRIDE),
	.KSIZE(KSIZE),
	.BURST(BURST),
	.POX(POX),
	.POY(POY)
)u_sender(
	.*);

always #50 clk = ~clk;

task data_gen;
	foreach(data[i]) data[i] = i;
endtask

initial begin
	clk = 0;
	rst_n = 0;
	data_load = 0;
	rvalid = 0;
	rdata = 0;
	@(posedge clk);
	rst_n = 1;
	repeat(3) @(posedge clk);

	data_gen;
	->data_gen_done;
end

always@(data_gen_done) begin
	data_load = 1;
	repeat(6) @(posedge clk);
	foreach(data[i]) begin
		//BURST = 32
		for(int j = 0; j < 32; j++) begin
			rvalid = 1;
			rdata = data[(i+j)%1024];
			@(posedge clk);
		end
		rvalid = 0;
		//repeat(6) @(posedge clk);
		repeat(9) @(posedge clk);
	end
	$stop;
end


endmodule
