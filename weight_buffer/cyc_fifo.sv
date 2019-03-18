module cyc_fifo#(
	parameter DW = 32,
	parameter DEPTH = 9
)(
	input clk,
	input rst_n,

	input [DW-1:0] 	i_data,
	input 					i_valid,

	input 					o_ready,
	output[DW-1:0]	o_data,
	output 					full,
	output 					empty
);

reg [DW-1:0] mem[DEPTH];
reg [15:0] rptr_r;
reg [15:0] wptr_r;
reg [DW-1:0] o_data_r;

//write 
assign full = (wptr_r == DEPTH-1);
assign empty = (rptr_r == DEPTH-1);
assign o_data = o_data_r;

always @(posedge clk) begin
	if (~rst_n) wptr_r <= 0;
	else if (full) wptr_r <= 0;
	else if (i_valid) wptr_r <= wptr_r + 1;
	else;
end

always @(posedge clk) begin
	if (i_valid) mem[wptr_r] <= i_data;
	else;
end

//read
// when to output the pixel?
// get blkend? or something else?
// o_ready must last for the same period
// of dwpe_ena
always @(posedge clk) begin
	if (~rst_n) rptr_r <= 0;
	else if (empty) rptr_r <= 0;
	else if (o_ready) rptr_r <= rptr_r + 1;
	else;
end

always @(posedge clk) begin
	if (o_ready) o_data_r <= mem[rptr_r];
	else ;
end

endmodule
