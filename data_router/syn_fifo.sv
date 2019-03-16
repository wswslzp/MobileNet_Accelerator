module syn_fifo#(
	parameter DW = 32,
	parameter STRIDE = 2,
	parameter BUFW = 32
)(
	input 				 	clk,

	input 					fifo_read,
	input [DW-1:0] 	i_data[BUFW],
	output[DW-1:0] 	o_data[BUFW]
);

reg [DW-1:0] mem[STRIDE][BUFW];

assign o_data = mem[0][0:BUFW-1];

//always@(posedge clk) begin
//	//if (fifo_read) begin
////	for(int i = 0; i < BUFW; i++) begin
////		if (fifo_read) 
////			mem[i] <= i_data[i];
////		else ;
////	end
////	end
//
//	for(int i = 0; i < STRIDE; i++) begin
//		for(int j = 0; j < BUFW; j++) begin
//			if (i == STRIDE-1) begin
//				if
//end
//
genvar i, j;
generate 

for(i = 0; i < STRIDE; i++) begin
	for( j = 0; j < BUFW; j++) begin
		if (i == STRIDE-1) begin
			always @(posedge clk) begin
				if (fifo_read) 
					mem[STRIDE-1][j] <= i_data[j];
				else;
			end
		end else begin
			always @(posedge clk) begin
				if (fifo_read) 
					mem[i][j] <= mem[i+1][j];
				else;
			end
		end
	end
end
endgenerate


endmodule
