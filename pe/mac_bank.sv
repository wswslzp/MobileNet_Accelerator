//=============================================================================
//     FileName: mac_bank.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:36:40
//      History:
//=============================================================================
module mac_bank#(
	parameter DW = 32,
	parameter POX= 3,
	parameter NMAX= 9
)(
	input [DW-1:0] 	data[POX],
	input [DW-1:0]	weight,
	output [DW-1:0]	result[POX],
	output 					cnt_c[POX],

	input 					clk,
	input 					rst_n,
	input 					ena
);

genvar i;
generate 
	for (i = 0; i < POX; i++) begin : macs
		mac#(.DW(DW),.NMAX(NMAX)) u_mac(
							 .clk,
							 .rst_n,
							 .ena,
							 .data(data[i]),
							 .weight,
							 .result(result[i]),
							 .cnt_c(cnt_c[i])
						 );
	end
endgenerate


endmodule
