module syn_fifo#(
	parameter DW = 32,
	parameter BUFW = 32
)(
	input 				 	clk,

	input 					fifo_read,
	input [DW-1:0] 	i_data[BUFW],
	output[DW-1:0] 	o_data[BUFW]
);

reg [DW-1:0] mem[BUFW];

assign o_data = mem[0:BUFW-1];

always@(posedge clk) begin
	//if (fifo_read) begin
	for(int i = 0; i < BUFW; i++) begin
		if (fifo_read) 
			mem[i] <= i_data[i];
		else ;
	end
//	end
end


endmodule
