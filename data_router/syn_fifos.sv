module syn_fifos#(
	parameter DW = 32,
	parameter BUFW = 32,
	parameter POY = 3
)(
	input 		clk,

	input 		fifo_read,
	input [DW-1:0] i_data[POY-1][BUFW],
	output[DW-1:0] o_data[POY-1][BUFW]
);

genvar i;
generate 

for(i = 0; i < POY-1; i++) begin
	syn_fifo u_syn_fifo#(
		.DW,
		.BUFW)(
		.clk,
		.fifo_read,
		.i_data(i_data[i]),
		.o_data(o_data[i]));
end
endgenerate

endmodule
