module mac #(
	parameter DW = 32,
	parameter NMAX = 64
) (
	input [DW-1:0]	data,
	input [DW-1:0] 	weight,
	output[DW-1:0]	result,
	output 					cnt_c,

	input 					ena,
	input 					clk,
	input 					rst_n
);

reg [DW-1:0]	partial_sum;
reg [5:0]			cnt;

wire [2*DW-1:0] product = data * weight;
wire [2*DW-1:0] partial_sum_nxt = partial_sum + product;

assign cnt_c = (cnt == (NMAX));
assign result = cnt_c ? partial_sum[DW-1:0] : 'b0;

always@(posedge clk) begin
	if (~rst_n) partial_sum <= 'b0;
	else if (cnt_c == 1'b1) partial_sum <= 'b0;
	else if (ena == 1'b1) partial_sum <= partial_sum_nxt[DW-1:0];
end

always@(posedge clk) begin
	if (~rst_n) cnt <= 'b0;
	else if (~ena) cnt <= 'b0;
	else begin
		if (cnt_c == 1'b1) cnt <= 'b0;
		else cnt <= cnt + 6'b1;
	end
end


endmodule
