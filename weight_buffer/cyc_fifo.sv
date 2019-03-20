module cyc_fifo#(
	parameter DW = 32,
	parameter DEPTH = 9
)(
	input clk,
	input rst_n,

	input [DW-1:0] 	i_data,
	//i_valid shall not directly connect to 
	//rvalid which usually last for more than
	//k**2 cycles.
	input 					i_valid,
	input 					weight_load,

	input 					o_ready,
	output[DW-1:0]	o_data,
	output 					full,
	output 					empty
);

reg [DW-1:0] mem[DEPTH];
reg [15:0] rptr_r;
reg [15:0] wptr_r;
reg [DW-1:0] o_data_r;

wire wptr_r_f = (wptr_r == DEPTH-1);
wire rptr_r_f = (rptr_r == DEPTH-1);
wire wptr_r_e = (wptr_r == 0);
wire rptr_r_e = (rptr_r == 0);

//write 
assign full = (wptr_r == rptr_r-1)
						&&(wptr_r_f & rptr_r_e);
assign empty = (rptr_r == wptr_r-1)
						 &&(rptr_r_f & wptr_r_e);
assign o_data = o_data_r;

always @(posedge clk) begin
	if (~rst_n) wptr_r <= 0;
	else if (wptr_r_f) wptr_r <= 0;
	else if (i_valid & ~full) wptr_r <= wptr_r + 1;
	else;
end

always @(posedge clk) begin
	if (i_valid & ~full) mem[wptr_r] <= i_data;
	else;
end

// read
// when to output the pixel?
// get blkend? or something else?
// o_ready must last for the same period
// of dwpe_ena
always @(posedge clk) begin
	if (~rst_n) rptr_r <= 0;
	else if (rptr_r_f) rptr_r <= 0;
	else if (weight_load) rptr_r <= DEPTH-3;
	else if (o_ready & ~empty) rptr_r <= rptr_r + 1;
	else;
end

always @(posedge clk) begin
	if (o_ready & ~empty) o_data_r <= mem[rptr_r];
	else ;
end

endmodule
