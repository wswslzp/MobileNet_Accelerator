module dwpe #(
	parameter DW = 32,
	parameter POX = 16
)(
	input 					clk,
	input 					rst_n,
	input 					dwpe_ena,

	input [DW-1:0] 	pixel_array[POX-1:0],

	input [DW-1:0]	weight,
	output[DW-1:0]	result[POX-1:0],
	output 					result_valid[POX]
);

wire [DW-1:0] mac_result[POX];

mac_bank mac_bank_u#(.DW,
										 .POX,
										 .NMAX(9)
									 )(
										 .clk,
										 .rst_n,
										 .ena(dwpe_ena),
										 .data(pixel_array),
										 .weight(weight),
										 .result(mac_result),
										 .cnt_c(result_valid)
									 );
relu relu_u#(.DW,
						 .POX,
						 .NMAX(9)
					 )(
						 .data(mac_result),
						 .result
					 );





endmodule
