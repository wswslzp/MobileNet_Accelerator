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
	output[28:0]		col,

	output[DW-1:0]	dwpixel_array[POY][POX],
	output 					dw_ena,
	// this group of signals are temporally needless
	output[DW-1:0]	pwpixel_array[POY]
);

wire [1:0] reg_array_cmd;
wire 			 fifo_read;

buffer_if u_buffer_if#(.KSIZE, 
					 .POY,
					 .STRIDE
				 )(
					 .clk,
					 .rst_n,
					 .blkend,
					 .rpsel,
					 .bank,
					 .row,
					 .col,
					 .dw_comp,
					 .reg_array_cmd,
					 .fifo_read
				 );

				 //TODO: link the submodule

endmodule

