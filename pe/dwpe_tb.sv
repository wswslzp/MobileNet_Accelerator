module dwpe_tb;

logic clk, rst_n, pe_ena;
logic [DW-1:0] pixel_array[POX], 
							 weight,
							 result[POX];
logic result_valid[POX];

timeunit 1ns;
timeprecision 1ps;

dwpe udwpe#(32,16)(.*);

always #50 clk <= ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	pe_ena = 0;
	foreach(pixel_array[i]) pixel_array[i] = 0;
	weight = 0;
	
	repeat(5) @(posedge clk);
	rst_n = 1;


end

endmodule
