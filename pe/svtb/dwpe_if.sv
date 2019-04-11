//=============================================================================
//     FileName: dwpe_if.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:37:06
//      History:
//=============================================================================
interface #(
	parameter DW = 32,
	POX = 16,
	KSIZE = 3
) dwpe_if(
	input bit clk
);

logic rst_n, dwpe_ena, result_valid[POX]
logic [DW-1:0] pixel_array[POX], result[POX], weight;

// include all synchronized signals 
// generated or sampled by test
clocking cb@(posedge clk);
	output dwpe_ena;
	output [DW-1:0] pixel_array[POX];
	output [DW-1:0] weight;
	input [DW-1:0]	result[POX];
	output					result_valid[POX];
endclocking

modport test(
	clocking cb,
	output   rst_n
);

modport dut(
	input 					clk,
	input 					rst_n,
	input 					dwpe_ena,

	input  	pixel_array,

	input 	weight,
	output	result,
	output 					result_valid
);

endinterface 
