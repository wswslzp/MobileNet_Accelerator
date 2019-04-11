//=============================================================================
//     FileName: relu.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:36:50
//      History:
//=============================================================================
module relu#(
	parameter DW = 32,
	parameter POX=3
)(
	input [DW-1:0] data[POX],
	output[DW-1:0] result[POX]
);

genvar i;
generate
	for(i = 0; i < POX; i++) begin
		assign result[i] = data[i][DW-1] ? 'b0 : data[i];
	end
endgenerate

endmodule
