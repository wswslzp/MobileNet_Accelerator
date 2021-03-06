//=============================================================================
//     FileName: data_router_if_sim.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:35:19
//      History:
//=============================================================================
module data_router_if_sim#(
	parameter DW = 32,
	POY = 3,
	POX = 16,
	KSIZE = 3,
	STRIDE = 1,
	BUFW = 32// bufw = burst
)(
	input 						clk,
	input 						rst_n,

	// to data router 
	output [DW-1:0] 	rdata[POY][BUFW],
	input [1:0]				rpsel,
	input [7:0]				rbank,
	input [7:0]				rrow,
	input [27:0]			rcol,

	// from sender 
	input 						wvalid,
	input [DW-1:0]		wdata,
	input [7:0] 			wbank,
	input [7:0]				wrow,
	input [27:0] 			wcol
);

localparam 
BUFH = 2*STRIDE,
RAL = ((POX-1)*STRIDE+KSIZE),
LM	 = ((STRIDE+1)*POY-STRIDE);

localparam RR = 2'b00, BR = 2'b01, RP = 2'b10, NE = 2'b11;

reg [DW-1:0] data_r[POY][BUFW];
reg [DW-1:0] indata[POY][BUFH][BUFW];

assign rdata = data_r;

// address and data must be available
// at the same cycle.
always@(posedge clk) begin
	if(wvalid) indata[wbank][wrow][wcol] <= wdata;
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
