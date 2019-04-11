//=============================================================================
//     FileName: dwpe.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:36:18
//      History:
//=============================================================================
// without batchnorm
module dwpe #(
	parameter DW = 32,
	parameter POX = 16,
	parameter KSIZE = 3
)(
	input 					clk,
	input 					rst_n,
	input 					dwpe_ena,

	input [DW-1:0] 	pixel_array[POX-1:0],

	input [DW-1:0]	weight,
	output[DW-1:0]	result[POX-1:0],
	output 					result_valid[POX]
);

wire [DW-1:0] mac_result[POX];

mac_bank#(.DW(DW),
				 .POX(POX),
				 .NMAX(KSIZE**2)
				 ) u_mac_bank (
										 .clk,
										 .rst_n,
										 .ena(dwpe_ena),
										 .data(pixel_array),
										 .weight(weight),
										 .result(mac_result),
										 .cnt_c(result_valid)
									 );
relu#(.DW(DW),
		 .POX(POX)
		 ) u_relu (
						 .data(mac_result),
						 .result
					 );





endmodule
