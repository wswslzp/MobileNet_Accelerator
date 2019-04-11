//=============================================================================
//     FileName: dwpe_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:36:30
//      History:
//=============================================================================
`timescale 1ns/1ns
module dwpe_tb;

parameter POX = 6, DW = 32, KSIZE = 3;
parameter NMAX = KSIZE**2;

logic clk, rst_n, dwpe_ena;
logic [DW-1:0] pixel_array[POX], 
							 weight,
							 result[POX];
logic result_valid[POX];

//timeunit 1ns;
//timeprecision 1ps;

int pixel_input[32];
int tresult[POX];
event data_generate_done;
bit result_valid_bit; 

assign result_valid_bit = result_valid[0];

task automatic data_generate(ref int pixel_input[32]);
	foreach(pixel_input[i]) pixel_input[i] = $random%8'hff;
	weight = 3%9;
endtask

task true_result;
	foreach(tresult[i]) tresult[i] = 0;
	foreach(pixel_array[i]) begin
		for(int j = 0; j < NMAX; j++) 
			tresult[i] += weight * pixel_input[i+j];
		$display("tresult_%d is %d", i, tresult[i]);
	end
endtask


dwpe#(DW,POX,KSIZE) u_dwpe (.*);

// NMAX=9
always #50 clk <= ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	dwpe_ena = 0;
	foreach(pixel_input[i]) pixel_input[i] = 0;
	weight = 0;
	
	repeat(5) @(posedge clk);
	rst_n = 1;
	repeat(10) @(posedge clk);

	// generate data needed
	repeat(10) begin
		data_generate(pixel_input);
		true_result;
		->data_generate_done;
		@(negedge result_valid_bit);
		repeat(50) @(posedge clk);
	end
	$stop;

end

genvar i;
generate 
for(i = 0; i < POX; i++) begin
	assign pixel_array[i] = pixel_input[i];
end
endgenerate

always @(data_generate_done) begin
	/*@(posedge clk) */dwpe_ena <= 1;
	@(posedge result_valid_bit) dwpe_ena <= 0;
end

// NMAX = 9 means that regarray shall shift 9-1 times
// also means that MAC shall accumulate 9 times.
always @(data_generate_done) begin
	for(int i = 0; i < NMAX-1; i++) begin // shift 8 times
		@(posedge clk) 
		foreach(pixel_input[j]) begin
			pixel_input[j] = pixel_input[j+1];
		end
	end
end

endmodule
