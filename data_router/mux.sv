//=============================================================================
//     FileName: mux.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:33:53
//      History:
//=============================================================================
module mux#(
	parameter DW = 1,
	parameter POY = 3,
	parameter BUFW = 32
)(
	input [DW-1:0] 	idata[POY][BUFW],
	// This bank signal's width is fixed,
	// which means that bank's quantity cannot 
	// be configured more than 4.
	input [7:0]			bank, 
	output reg [DW-1:0]	odata[BUFW]
);

always@* begin
	for(int i = 0; i < POY; i++) begin
		if (bank == i) odata = idata[i];
		//else 
		//	for(int j = 0; j < BUFW; j++) 
		//		odata[j] = 'x;
	end
end


endmodule
