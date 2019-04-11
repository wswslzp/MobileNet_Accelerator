//=============================================================================
//     FileName: axi_if.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:34:37
//      History:
//=============================================================================
interface axi_bus_if#(
	parameter DW = 32,
	parameter AW = 32
)(
	input logic clk
);

logic [AW-1:0] 	araddr;
logic [3:0]		 	arburst;
logic 					arvalid;
logic 					arready;
logic 					rvalid;
logic [DW-1:0]	rdata;
logic 					rlast;

//UNUSED
//clocking dp_cb @(posedge clk);
//	output araddr, arburst, arvalid;
//	input arready, rvalid, rdata, rlast;
//endclocking

clocking dram_cb @(posedge clk);
	input araddr, arburst, arvalid;
	output arready, rvalid, rdata, rlast;
endclocking 

//modport dp 
//(
//	clocking dp_cb
//);

modport dram
(
	clocking dram_cb
);

endinterface
