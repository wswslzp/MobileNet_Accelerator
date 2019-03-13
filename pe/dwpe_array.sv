module dwpe_array#(
	parameter DW = 32,
	parameter POX= 16,
	parameter POY= 3
)(
	input [DW-1:0] pixel_array[POY][POX],
	input [DW-1:0] weight,
	output[DW-1:0] result[POY][POX],
	output 				 result_valid[POY][POX],

	input 				 clk,
	input 				 rst_n,
	input 				 pe_ena
);

wire [DW-1:0] 

genvar i, j;
generate 
	for (i = 0; i < POY; i++) begin:pe_col
		dwpe u_dwpe#(.DW,
								 .POX
							 )(.clk,
								 .rst_n,
								 .pe_ena,
								 .pixel_array(pixel_array[i]),
								 .weight(weight),
								 .result(result[i]),
								 .result_valid(result_valid[i])
							 );
	end:pe_col
endgenerate


endmodule
