module data_router#(
	parameter DW = 32,
	parameter POY = 3,
	parameter POX = 16,
	parameter BUFW = 32,
	parameter KSIZE = 3,
	parameter STRIDE = 1
)(
	input 					clk,
	input 					rst_n,

	// we didn't implement the pw function
	// so this signal is temporally needless
	input 					dw_comp,


	input 					blkend,
	input [DW-1:0]  data[POY][BUFW],
	output[1:0]			rpsel,
	output[1:0]			bank,
	output[1:0]			row,
	output[27:0]		col,

	output[DW-1:0]	dwpixel_array[POY][POX],
	output 					dwpe_ena,
	// this group of signals are temporally needless
	output[DW-1:0]	pwpixel_array[POY]
);

wire [1:0] reg_array_cmd;
wire 			 fifo_read;
wire [DW-1:0] reg_array_dat[POY][BUFW];
wire [DW-1:0] fifo_i_data[POY-1][BUFW], fifo_o_data[POY-1][BUFW];

buffer_if #(.KSIZE(KSIZE), 
					 .POY(POY),
					 .STRIDE(STRIDE)
				 )u_buffer_if(
					 .clk,
					 .rst_n,
					 .blkend,
					 .rpsel,
					 .bank,
					 .row,
					 .col,
					 .dw_comp,
					 .reg_array_cmd,
					 .dwpe_ena,
					 .fifo_read
				 );

mux #(
	.DW(DW),
	.POY(POY),
	.BUFW(BUFW))u_mux(
	.idata(data),
	.bank(bank),
	.odata(reg_array_dat[POY-1])
);

genvar i;
generate 

for(i = 0;i < POY;i++) begin:reg_arrays
	//reg_array u_reg_array#(
	//	.DW, 
	//	.BUFW,
	//	.KSIZE,
	//	.POX,
	//	.STRIDE,
	//	.LASTONE(0))(
	//	.
	//if (i != POY-1) begin
	//	assign reg_array_dat[i] = data[i];
	//	
	//end 
	//if (i != 0) begin
	//	assign fifo_i_data[i] = reg_array_dat[i];
	//end
	if (i != 0 && i != POY-1) begin
		assign reg_array_dat[i] = data[i];
		assign fifo_i_data[i-1] = reg_array_dat[i];
		reg_array #(// reg_array i
			.DW(DW),
			.BUFW(BUFW),
			.KSIZE(KSIZE),
			.POX(POX),
			.STRIDE(STRIDE),
			.LASTONE(0))u_reg_array(
			.clk,
			.rst_n,
			.i_buf_data(reg_array_dat[i]),
			.i_fifo_data(fifo_o_data[i]),
			.o_pe_data(dwpixel_array[i]),
			.reg_array_cmd);
		syn_fifo #(// syn_fifo i
			.DW(DW),
			.BUFW(BUFW))u_syn_fifo(
			.clk,
			.fifo_read,
			.i_data(fifo_i_data[i]),
			.o_data(fifo_o_data[i]));
	end 
	else if (i == 0) begin
		assign reg_array_dat[0] = data[0];
		reg_array#(
			.DW(DW),
			.BUFW(BUFW),
			.KSIZE(KSIZE),
			.POX(POX),
			.STRIDE(STRIDE),
			.LASTONE(0)) u_reg_array(
			.clk,
			.rst_n,
			.i_buf_data(reg_array_dat[0]),
			.i_fifo_data(fifo_o_data[0]),
			.o_pe_data(dwpixel_array[0]),
			.reg_array_cmd);
		syn_fifo #(// syn_fifo i
			.DW(DW),
			.BUFW(BUFW))u_syn_fifo(
			.clk,
			.fifo_read,
			.i_data(fifo_i_data[0]),
			.o_data(fifo_o_data[0]));
	end else begin
		//assign reg_array_dat[POY-1] = mux.odata;
		assign fifo_i_data[POY-2] = reg_array_dat[POY-1];
		reg_array #(
			.DW(DW),
			.BUFW(BUFW),
			.KSIZE(KSIZE),
			.POX(POX),
			.STRIDE(STRIDE),
			.LASTONE(1))u_reg_array(
			.clk,
			.rst_n,
			.i_buf_data(reg_array_dat[POY-1]),
			.i_fifo_data(),
			.o_pe_data(dwpixel_array[POY-1]),
			.reg_array_cmd);
	end
end
endgenerate

	


endmodule

