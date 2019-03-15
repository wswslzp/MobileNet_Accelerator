module buffer_if#(
	parameter KSIZE = 3,
	parameter POY = 3,
	parameter STRIDE = 1
)(
	input 					clk,
	input 					rst_n,

	// input buffer
	input 					blkend,
	output[1:0]			rpsel,
	output[1:0]			bank,
	output[1:0]			row,
	output[27:0]  	col,

	// glb_ctrl
	// we didn't implement the pw function
	// so this signal is temporally needless
	input 					dw_comp, 
	//input [1:0] 		stride,

	// reg_array control
	// reg_array_cmd = 2'b00, take pixel from buffer if
	// reg_array_cmd = 2'b01, shift pixel 
	// reg_array_cmd = 2'b10, take pixel from fifo to reg array except last one,
	// 												and last one takes pixel from buffer
	output[1:0]			reg_array_cmd,
	output 					fifo_read,
	output 					dwpe_ena// to dwpe
);

reg [3:0] shift_cnt; //shift maxium smaller than 9
reg [1:0] init_trans_cnt; //stride maxium is 2
reg [1:0] ntrans_cnt; //poy=3,stride=1,2
reg [1:0] bank_r;
reg [1:0] rpsel_r;
reg [1:0] row_r;
reg [27:0] col_r;
reg [1:0] reg_array_cmd_r;
reg bank_r_f_r;
reg fifo_read_r;
reg dwpe_ena_r;

reg [2:0] state, nstate;

//RR: rowrow, all row; BR: a row of bank; RP: a pixel of a row of a bank
//NE: reserve 
localparam RR = 2'b00, BR = 2'b01, RP = 2'b10, NE = 2'b11;
localparam IDLE = 3'h0, INITTRAN_1 = 3'h1, INITTRAN_2 = 3'h2,
					 SHIFT = 3'h3, NTRAN_1 = 3'h4, NTRAN_2 = 3'h5;

wire shift_cnt_f = (shift_cnt == (KSIZE - 2));
wire init_trans_cnt_f = (init_trans_cnt == STRIDE - 1);
wire ntrans_cnt_f = (ntrans_cnt == (POY - STRIDE - 1));
wire bank_r_f = (bank_r == POY-1);

assign bank = bank_r;
assign rpsel = rpsel_r;
assign row = row_r;
assign col = col_r;
assign reg_array_cmd = reg_array_cmd_r;
assign dwpe_ena = dwpe_ena_r;

always@(posedge clk) begin
	if (~rst_n) bank_r_f_r <= 0;
	else if (bank_r_f) bank_r_f_r <= 1;
end

always@(posedge clk) begin
	if (~rst_n) state <= IDLE;
	else state <= nstate;
end

always@* begin
	case(state)
		IDLE: nstate = blkend ? INITTRAN_1 : IDLE;
		INITTRAN_1: nstate = INITTRAN_2;
		INITTRAN_2: nstate = SHIFT;
		SHIFT: nstate = ~shift_cnt_f	? SHIFT :
										~init_trans_cnt_f? INITTRAN_1 :
										~ntrans_cnt_f? NTRAN_1 :
																  IDLE;
		NTRAN_1: nstate = NTRAN_2;
		NTRAN_2: nstate = SHIFT;
		default: nstate = IDLE;
	endcase
end

task idle;
	shift_cnt <= 0;
	init_trans_cnt <= 0;
	ntrans_cnt <= 0;
	bank_r <= 0;
	rpsel_r <= NE;
	row_r <= 0;
	col_r <= 0;
	reg_array_cmd_r <= 0;
	fifo_read_r <= 0;
endtask 

task init_trans_read; // 3 cycles to response
	rpsel_r <= RR;
	row_r <= 2'b00;
	init_trans_cnt <= ~init_trans_cnt_f ? init_trans_cnt + 2'h1 : '0;
endtask

task init_trans_reci;
	reg_array_cmd_r <= 2'b00;
	fifo_read_r <= 1;
	dwpe_ena_r <= 1'b1;
endtask 

task shift;
	fifo_read_r <= 0;
	shift_cnt <= ~shift_cnt_f ? shift_cnt + 4'h1 : '0;
	reg_array_cmd_r <= 2'b01;
endtask 

task norm_trans_read;
	rpsel_r <= BR;
	bank_r <= bank_r_f ? 2'h0 : bank_r + 2'h1;
	row_r <= bank_r_f_r + 2'h1;
	ntrans_cnt <= ~ntrans_cnt_f ? ntrans_cnt + 1 : '0;
endtask

task norm_trans_reci;
	reg_array_cmd_r <= 2'b10;
endtask


always@(posedge clk) begin
	case(state)
		IDLE: idle;
		INITTRAN_1: init_trans_read;
		INITTRAN_2: init_trans_reci;
		SHIFT: shift;
		NTRAN_1: norm_trans_read;
		NTRAN_2: norm_trans_reci;
		default: idle;
	endcase
end


endmodule
