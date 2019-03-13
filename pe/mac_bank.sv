module mac_bank#(
	parameter DW = 32,
	parameter POX= 3,
	parameter NMAX= 9
)(
	input [DW-1:0] 	data[POX],
	input [DW-1:0]	weight,
	output [DW-1:0]	result[POX],
	output 					cnt_c[POX],

	input 					clk,
	input 					rst_n,
	input 					ena
);

genvar i;
generate 
	for (i = 0; i < POX; i++) begin : macs
		mac u_mac#(.DW(DW),
							 .NMAX(NMAX)
						 )(
							 .clk,
							 .rst_n,
							 .ena,
							 .data(data[i]),
							 .weight,
							 .result(result[i]),
							 .cnt_c(cnt_c[i])
						 );
	end
endgenerate


endmodule
