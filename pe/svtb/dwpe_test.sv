//=============================================================================
//     FileName: dwpe_test.sv
//         Desc: 
//       Author: Liao Zhengpeng
//        Email: wswslzp@outlook.com
//     HomePage:  
//      Version: 0.0.1
//   LastChange: 2019-04-11 19:37:11
//      History:
//=============================================================================
program dwpe_test(
	dwpe_if.test if_t
);

// Don't have to declare parameter here?
parameter POX = 6, DW = 32, KSIZE = 2;
parameter NMAX = KSIZE**2;


int pixel_input[32];
int tresult[POX];
event data_generate_done;
bit result_valid_bit; 

//No problem?
assign result_valid_bit = result_valid[0];
genvar i;
generate 
for(i = 0; i < POX; i++) begin
	assign pixel_array[i] = pixel_input[i];
end
endgenerate

task automatic data_generate(ref int pixel_input[32]);
	foreach(pixel_input[i]) pixel_input[i] = $random%8'hff;
	weight = 3%9;
endtask

task true_result;
	foreach(tresult[i]) tresult[i] = 0;
	foreach(pixel_array[i]) begin
		for(int j = 0; j < NMAX; j++) 
			tresult[i] += weight * pixel_input[i+j];
		$display("tresult_%d is %d", i, tresult[i]);
	end
endtask


initial begin
	// NO need to initialize clock
	// because clock's data type is 
	// bit which only has two value 0 and 1
	if_t.rst_n <= 0;
	if_t.dwpe_ena <= 0;
	foreach(pixel_input[i]) pixel_input[i] <= 0;
	if_t.weight <= 0;
	
	repeat(5) @(if_t.cb);
	if_t.rst_n <= 1;

	repeat(10) begin
		data_generate(pixel_input);
		true_result;
		->data_generate_done;
		@(posedge result_valid_bit);
	end

	// the program has forever block
	// manually invoke this system function
	// to exit program
	$exit;
end

// In this way, program will never finish
// unless we manually write $exit;
initial begin
	forever begin
		@(data_generate_done);
		@if_t.clk dwpe_ena <= 1;
		@(posedge result_valid_bit) dwpe_ena <= 0;
	end
end

initial begin
	forever begin
		@(data_generate_done);
		for(int i = 0; i < NMAX-1; i++) begin
			@(if_t.clk);
			foreach(pixel_input[j]) begin
				pixel_input[j] = pixel_input[j+1];
			end
		end
	end
end


endprogram
