module reg_arrays#(
	parameter DW = 32,
					  POY = 16,
					  BUFW = 32,
						KSIZE = 3,
						STRIDE = 1,
						POX = 16
)(
	input clk,
	input rst_n,
	
	input [DW-1:0]	i_buf_data[POY][BUFW],
	input [DW-1:0]	i_fifo_data[POY][BUFW],
	output[DW-1:0] 	o_pe_data[POY][POX],

	input [1:0]			bank,
	input [1:0] 		reg_array_cmd
);


genvar i;
generate 

for(i = 0; i < POY; i++) begin: reg_arrays
	if (i != POY-1) begin
		reg_array u_reg_array#(
			.DW, 
			.BUFW,
			.KSIZE,
			.POX,
			.STRIDE,
			.LASTONE(0))(
			.clk,
			.rst_n,
			.i_buf_data(data[i]),
			.i_fifo_data(i_fifo_data[i]),
			.o_pe_data(dwpixel_array[i]),
			.reg_array_cmd);	
	end else begin
		wire [DW-1:0] mux2reg[BUFW];
		reg_array u_reg_array#(
			.DW, 
			.BUFW,
			.KSIZE,
			.POX,
			.STRIDE,
			.LASTONE(1))(
			.clk,
			.rst_n,
			.i_buf_data(mux2reg),//TODO
			.i_fifo_data(),
			.o_pe_data(dwpixel_array[i]),
			.reg_array_cmd);	
		mux u_mux#(
			.DW,
			.POY,
			.BUFW)(
			.idata(i_buf_data),
			.bank,
			.odata(mux2reg));
	end

end:reg_arrays
endgenerate



endmodule
