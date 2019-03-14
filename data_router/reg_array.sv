module reg_array#(
	parameter DW = 32,
	parameter BUFW = 32,
	parameter KSIZE = 3,
	parameter POX = 16
)(
	input 					clk,
	input 					rst_n,

	input [DW-1:0] 	i_buf_data[BUFW],
	input [DW-1:0] 	i_fifo_data[BUFW],
	output[DW-1:0] 	o_pe_data[POX],

	input [1:0]			stride,
	input [1:0] 		reg_array_cmd
);

localparam BUFIN = 2'b00,
					 SHIFT = 2'b01,
					 FIFOI = 2'b10;

reg [DW-1:0] mem[BUFW];

always@* begin
	j

always@(posedge clk) begin
	case(reg_array_cmd) 
		BUFIN: mem <= i_buf_data;
		SHIFT: 
			for(int i = 0; i < (BUFW-KSIZE+1); i++) 
				mem[i] <= mem[i+1];
		FIFOI: mem <= i_fifo_data;
	endcase
end


endmodule
