module data_router_if_sim#(
	parameter DW = 32,
	parameter POY = 3,
	parameter POX = 16,
	parameter BUFW = 32,
	parameter BUFH = 3,
	parameter KSIZE = 3,
	parameter STRIDE = 1
)(
	input 						clk,
	input 						rst_n,

	output [DW-1:0]		data[POY][BUFW],
	output reg				blkend,
	input [7:0]				bank,
	input [7:0]				row,
	input [27:0]			col,
	input [1:0]				rpsel
);

reg [DW-1:0] data_r[POY][BUFW];

assign data = data_r;

//RR: rowrow, all row; BR: a row of bank; RP: a pixel of first row of all bank
//NE: reserve 
localparam RR = 2'b00, BR = 2'b01, RP = 2'b10, NE = 2'b11;

reg [DW-1:0] indata[POY][BUFH][BUFW];

initial begin
	blkend = 0;
	for(int i = 0; i < POY; i++) begin
		for(int j = 0; j < BUFH; j++) begin
			for(int k = 0; k < BUFW; k++) begin
				indata[i][j][k] = 100*i+j+k;
			end
		end
	end
	repeat(10) @(posedge clk);
	blkend = 1;
	@(posedge clk);

	blkend = 0;
	repeat(100) @(posedge clk);
	for(int i = 0; i < POY; i++) begin
		for(int j = 0; j < BUFH; j++) begin
			for(int k = 0; k < BUFW; k++) begin
				indata[i][j][k] = 50*i+2*j+k;
			end
		end
	end
	repeat(10) @(posedge clk);
	blkend = 1;
	@(posedge clk);

	blkend = 0;

end

task rr;
	for(int i = 0; i < POY; i++) begin
		$display("indata[%d][%d][0]=%d", i, row, indata[i][row][0]);
		data_r[i] <= indata[i][row];
	end
endtask

task br;
	$display("indata[%d][%d][0]=%d", bank, row, indata[bank][row][0]);
	data_r[bank] <= indata[bank][row];
endtask

task rp;
	for(int i = 0; i < POY; i++) begin
		data_r[i][col] <= indata[i][row][col];
	end
endtask

task ne;
//	$display("WRONG INSTRUCTION");
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
