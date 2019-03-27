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
	output[7:0]			bank,
	output[7:0]			row,
	output[27:0]  	col,

	// glb_ctrl
	// we didn't implement the pw function
	// so this signal is temporally needless
	input [1:0]			dw_comp, 
	//input [1:0] 		stride,

	// reg_array control
	// reg_array_cmd = 2'b00, take pixel from buffer if
	// reg_array_cmd = 2'b01, shift pixel 
	// reg_array_cmd = 2'b10, take pixel from fifo to reg array except last one,
	// 												and last one takes pixel from buffer
	output[1:0]			reg_array_cmd[POY],
	output 					fifo_read,
	output 					dwpe_ena// to dwpe
);

reg [3:0] shift_cnt; //shift maxium smaller than 9
reg [1:0] init_trans_cnt; //stride maxium is 2
reg [1:0] ntrans_cnt; //poy=3,stride=1,2
reg [7:0] bank_r;
reg [1:0] rpsel_r;
reg [7:0] row_r;
reg [27:0] col_r;
reg [1:0] reg_array_cmd_r[POY];
reg bank_r_f_r;
//reg fifo_read_r;
reg dwpe_ena_r;
reg dwpe_ena_r_1;
reg ssd_r_1, ssd_r_2;

reg [2:0] state, nstate;

//RR: rowrow, all row; BR: a row of bank; RP: a pixel of a row of a bank
//NE: reserve 
localparam IB = 2'b00, SF = 2'b01, IF = 2'b10;
localparam RR = 2'b00, BR = 2'b01, RP = 2'b10, NE = 2'b11;
localparam IDLE = 3'h0, INITTRAN_1 = 3'h1, INITTRAN_2 = 3'h2,
					 SHIFT = 3'h3, NTRAN_1 = 3'h4, NTRAN_2 = 3'h5;

wire shift_cnt_f = (shift_cnt == (KSIZE - 2));
wire init_trans_cnt_f = (init_trans_cnt == STRIDE);
wire ntrans_cnt_f = (ntrans_cnt == (POY - STRIDE)); 
wire bank_r_f = (bank_r == POY-1);
wire shift_state_detect = (state == SHIFT);

assign bank = bank_r;
assign rpsel = rpsel_r;
assign row = row_r;
assign col = col_r;
assign reg_array_cmd = reg_array_cmd_r;
assign dwpe_ena = dwpe_ena_r_1 | dwpe_ena_r;
assign fifo_read = ssd_r_2 & (~ssd_r_1);

//Trick to extend dwpe_ena to one more
//cycle than dwpe_ena_r
always @(posedge clk) begin
	dwpe_ena_r_1 <= dwpe_ena_r;
end

always @(posedge clk) begin
	if (~rst_n) {ssd_r_1, ssd_r_2} <= 2'b00;
	else {ssd_r_1, ssd_r_2} <= {ssd_r_2, shift_state_detect};
end

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
										~init_trans_cnt_f ? INITTRAN_2 :
										~ntrans_cnt_f ? NTRAN_1 :
																  IDLE;
		NTRAN_1: nstate = SHIFT;
		default: nstate = IDLE;
	endcase
end

task idle;
	dwpe_ena_r <= 0;
	shift_cnt <= 0;
	init_trans_cnt <= 0;
	ntrans_cnt <= 0;
	bank_r <= POY-1;
	rpsel_r <= NE;
	row_r <= 0;
	col_r <= 0;
	foreach(reg_array_cmd_r[i]) 
		reg_array_cmd_r[i] <= NE;
endtask 

task init_trans_read; // 3 cycles to response
	rpsel_r <= RR;
	row_r <= init_trans_cnt;
	init_trans_cnt <= ~init_trans_cnt_f ? init_trans_cnt + 2'h1 : '0;
endtask

task init_trans_reci;
	foreach(reg_array_cmd_r[i]) reg_array_cmd_r[i] <= IB;
	//dwpe_ena_r <= 1'b1;
endtask 

task shift;
	if (shift_cnt_f == 1'b1 && init_trans_cnt_f == 1'b1) begin
		rpsel_r <= BR;
		bank_r <= bank_r_f ? 0 : bank_r + 1;
		row_r <= bank_r_f ? row_r + 1 : row_r;
	end else if (shift_cnt_f == 1'b1 && init_trans_cnt_f != 1'b1) begin
		rpsel_r <= RR;
		row_r <= init_trans_cnt;
		init_trans_cnt <= ~init_trans_cnt_f ? init_trans_cnt + 2'h1 : '0;
	end else;
	dwpe_ena_r <= 1'b1;
	shift_cnt <= ~shift_cnt_f ? shift_cnt + 4'h1 : '0;
	foreach(reg_array_cmd_r[i]) reg_array_cmd_r[i] <= SF;
endtask 

task norm_trans_read;
	ntrans_cnt <= ~ntrans_cnt_f ? ntrans_cnt + 1 : '0;
	foreach(reg_array_cmd_r[i]) begin
		if(i == POY-1) reg_array_cmd_r[i] <= IB;
		else reg_array_cmd_r[i] <= IF;
	end
endtask

always@(posedge clk) begin
	case(state)
		IDLE: idle;
		INITTRAN_1: init_trans_read;
		INITTRAN_2: init_trans_reci;
		SHIFT: shift;
		NTRAN_1: norm_trans_read;
		default: idle;
	endcase
end


endmodule
