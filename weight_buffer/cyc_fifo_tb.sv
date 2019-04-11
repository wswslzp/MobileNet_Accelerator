//=============================================================================
//     FileName: cyc_fifo_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:37:25
//      History:
//=============================================================================
`timescale 1ns/1ns
module cyc_fifo_tb;

parameter DW = 32, DEPTH = 9;

logic clk, rst_n, i_valid, full, empty, o_ready;
logic [DW-1:0] i_data, o_data;

event data_generate_done, next_one;
bit [DW-1:0] data[DEPTH];
int base = 0;

always #50 clk = ~clk;

cyc_fifo#(
	.DW(DW),
	.DEPTH(DEPTH)
) u_cyc_fifo (
	.*);

task gen_data;
	foreach(data[i]) data[i] <= base * 10 + i;
	base++;
endtask

initial begin
	clk = 0;
	rst_n = 0;
	repeat(3) @(posedge clk);

	rst_n = 1;
	@(posedge clk);

	repeat(10) begin
		gen_data;
		->data_generate_done;
		@(next_one);
	end

	$stop;

end

always@(data_generate_done) begin
	@(posedge clk);
	foreach(data[i]) begin
		i_data <= data[i];
		i_valid <= 1'b1;
		@(posedge clk);
		o_ready <= 1'b1;
	end
	i_valid <= 1'b0;
	@(posedge clk);
	//o_ready <= 1'b0;
	repeat(100) @(posedge clk);
	->next_one;
end
	

endmodule
