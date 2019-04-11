//=============================================================================
//     FileName: dwpe_array.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:36:26
//      History:
//=============================================================================
module dwpe_array#(
	parameter DW = 32,
	parameter POX= 16,
	parameter POY= 3
)(
	input [DW-1:0] pixel_array[POY][POX],
	input [DW-1:0] weight,
	output[DW-1:0] result[POY][POX],
	output 				 result_valid[POY][POX],

	input 				 clk,
	input 				 rst_n,
	input 				 dwpe_ena
);

//wire [DW-1:0] 

genvar i, j;
generate 
	for (i = 0; i < POY; i++) begin:pe_col
		dwpe#(.DW(DW),
				 .POX(POX)
				 ) u_dwpe (.clk,
								 .rst_n,
								 .dwpe_ena,
								 .pixel_array(pixel_array[i]),
								 .weight(weight),
								 .result(result[i]),
								 .result_valid(result_valid[i])
							 );
	end:pe_col
endgenerate


endmodule
