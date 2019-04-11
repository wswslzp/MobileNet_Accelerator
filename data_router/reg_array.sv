//=============================================================================
//     FileName: reg_array.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:33:57
//      History:
//=============================================================================
module reg_array#(
	parameter DW = 32,
	parameter BUFW = 32,
	parameter KSIZE = 3,
	parameter POX = 16,
	parameter STRIDE = 1,
	parameter LASTONE = 0
)(
	input 					clk,
	input 					rst_n,

	input [DW-1:0] 	i_buf_data[BUFW],
	input [DW-1:0] 	i_fifo_data[BUFW],
	output[DW-1:0] 	o_pe_data[POX],
	output[DW-1:0] 	o_fifo_data[BUFW],

	input [1:0] 		reg_array_cmd
);

// IB: buffer in; SF: shift; IF: fifo in
localparam IB = 2'b00,
					 SF = 2'b01,
					 IF = 2'b10,
					 NE = 2'b11;

reg [DW-1:0] mem[BUFW];

assign o_fifo_data = mem;

//TODO: handle with STRIDE, parameterize the stride signal?yes
genvar i;
generate 
if (STRIDE == 1) begin//BUFW=POX
	for(i = 0; i < POX; i++) begin
		assign o_pe_data[i] = mem[i];
	end
end else if (STRIDE == 2) begin
	for(i = 0; i < POX; i++) begin
		assign o_pe_data[i] = mem[i*2];
	end
end else begin
	for(i = 0; i < POX; i++) begin
		assign o_pe_data[i] = 'x;
	end
end
endgenerate

always@(posedge clk) begin
	case(reg_array_cmd) 
		IB: mem <= i_buf_data;
		SF: 
			for(int i = 0; i < (BUFW-KSIZE+1); i++) 
				mem[i] <= mem[i+1];
		IF:begin //mem <= i_fifo_data; 
			// NO PROBLEM?
			if (LASTONE == 0) mem <= i_fifo_data;
			else mem <= i_buf_data;
		end
		//NE: //$display("IDLE");
	endcase
end


endmodule
