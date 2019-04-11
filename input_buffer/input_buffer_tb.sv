//=============================================================================
//     FileName: input_buffer_tb.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:35:30
//      History:
//=============================================================================
`timescale 1ns/1ns
module input_buffer_tb;

parameter 
	DW = 32,
	AW = 32,
	KSIZE = 3,
	POX = 15,
	POY = 3,
	STRIDE = 2, //BUFH = 2*2=4
	IW = 224,
	IH = 224,
	IN = 10, // Number of image
	BURST = 32,
	BUFW = BURST;

logic clk, rst_n, arvalid, arready, rlast, rvalid;
logic weight_load, result_valid, data_load, dw_comp;
logic init_addr_en, blkend, mapend;
logic [1:0] rpsel, reg_array_cmd[POY];
logic [7:0] rbank, rrow;
logic [3:0] arburst;
logic [27:0] rcol;
logic [AW-1:0] araddr, init_addr;
logic [DW-1:0] rdata, odata[POY][BUFW];
logic fifo_read, dwpe_ena;
logic [AW-1:0] init_addr_cnt = 0;
const int BUFH = 4, LM = (STRIDE + 1) * POY - STRIDE;

axi_bus_sim#(
	.DW(DW),
	.AW(AW),
	.IW(IW),
	.IH(IH),
	.IN(IN)
)
u_axi_bus_sim(
	.*);

input_buffer#(
	.DW(DW),
	.AW(AW),
	.KSIZE(KSIZE),
	.POX(POX),
	.POY(POY),
	.STRIDE(STRIDE),
	.IW(IW),
	.IH(IH),
	.BURST(BURST)
)u_input_buffer(
	.*);

buffer_if#(
	.KSIZE(KSIZE),
	.POY(POY),
	.STRIDE(STRIDE)
)u_buffer_if(
	.clk,
	.rst_n,
	.blkend,
	.rpsel,
	.bank(rbank),
	.row(rrow),
	.col(rcol),
	.dw_comp(),
	.reg_array_cmd,
	.fifo_read,
	.dwpe_ena
);

always #50 clk = ~clk;

initial begin
	const int RAL = (POX-1)*STRIDE+KSIZE;
	if(RAL > BUFW) $display("wrong pox");
	clk = 0;
	rst_n = 0;
	weight_load = 0;
	dw_comp = 0;
	init_addr_en = 0;
	rpsel = 0;
	rbank = 0;
	rrow = 0;
	rcol = 0;
	repeat(2) @(posedge clk);
	rst_n = 1;

	repeat(10) @(posedge clk);
	//data_load = 1;
	//init_addr_en = 1;
	init_addr = 32'ha;
	//@(posedge clk) init_addr_en = 0;

	//for(int i = 0; i < IH/BUFH; i++) begin
	//	$display("The %d block compute start", i);
	//	data_load = 1;
	//	if (i == 0) data_init_addr_en = 1;
	//	@(posedge clk);
	//	data_init_addr_en = 0;
	//	wait(blkend == 1);
	//	data_load = 0;
	//	@(negedge result_valid);
	//end

	//TODO: Mapend got some problem!
	repeat(IN) begin
		for(int i = 0; i < IH/LM; i++) begin
			for(int j = 0; j < IW/BUFW; j++) begin
				data_load = 1;
				if (i==0 && j==0) begin
					init_addr_en = 1;
					init_addr = init_addr_cnt;
					@(posedge clk) init_addr_en = 0;
				end
				wait(blkend==1);
				//alternative: @(posedge blkend);???
				data_load = 0;
				repeat(12) @(posedge clk);
				result_valid = 1;
				@(posedge clk);
				result_valid = 0;
			end
		end
		init_addr_cnt = init_addr_cnt + IH*IW;
	end

	//@(posedge blkend);
	//data_load = 0;
	//repeat(12) @(posedge clk);
	//result_valid = 1;
	//@(posedge clk);
	//result_valid = 0;

	repeat(100) @(posedge clk);
	$stop;

end

endmodule
