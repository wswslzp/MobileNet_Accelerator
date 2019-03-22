module data_router_if_sim#(
	parameter DW = 32,
	parameter POY = 3,
	parameter POX = 16,
	parameter KSIZE = 3,
	parameter STRIDE = 1
)(
	input 						clk,
	input 						rst_n,

	// to data router 
	output [DW-1:0] 	rdata[POY][BUFW],
	input [1:0]				rpsel,
	input [7:0]				rbank,
	input [7:0]				rrow,
	input [27:0]			rcol

	// from sender 
	input [DW-1:0]		wdata,
	input [7:0] 			wbank,
	input [7:0]				wrow,
	input [27:0] 			wcol
);

localparam 
BUFW = 2*STRIDE,
BUFW = (POX*STRIDE+KSIZE/2),
LM	 = ((STRIDE+1)*POY-STRIDE);

localparam RR = 2'b00, BR = 2'b01, RP = 2'b10, NE = 2'b11;

reg [DW-1:0] data_r[POY][BUFW];
reg [DW-1:0] indata[POY][BUFH][BUFW];

assign rdata = data_r;

// address and data must be available
// at the same cycle.
always@(posedge clk) begin
	indata[wbank][wrow][wcol] <= wdata;
end

task rr;
	for(int i = 0; i < POY; i++) begin
		data_r[i] <= indata[i][rrow];
	end
endtask

task br;
	data_r[rbank] <= indata[rbank][rrow];
endtask

task rp;
	for(int i = 0; i < POY; i++) begin
		data_r[i][rcol] <= indata[i][rrow][rcol];
	end
endtask

task ne;
	$display("WRONG INSTRUCTION");
endtask

always @(posedge clk) begin
	case(rpsel)
		RR: rr;
		BR: br;
		RP: rp;
		NE: ne;
	endcase
end


endmodule
