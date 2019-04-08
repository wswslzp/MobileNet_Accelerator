//simulate glbctrl
program data_path_test#(
	parameter int
	AW = 32,
	KSIZE = 3,
	IW = 32,
	IH = 32,
	IC = 3,
	BUFW = 32,
	BUFH = 4
)(
	input 								clk, 
	input 								rst_n,
	
	input 								blkend,
	input 								mapend,
	input 								result_valid,

	output logic 					data_load,
	//output logic 					weight_load,
	output logic 					dw_comp,
	output logic [AW-1:0] data_init_addr,
	output logic [AW-1:0] weight_init_addr,
	output logic 					data_init_addr_en
	//output logic 					weight_init_addr_en
);

initial 
	forever if(~rst_n) begin
		data_load = 0;
		//weight_load = 0;
		dw_comp = 0;
		data_init_addr = 0;
		weight_init_addr = 0;
		data_init_addr_en = 0;
		//weight_init_addr_en = 0;
		break;
	end

initial 
	begin
		wait(rst_n == 1);
		repeat(5) @(posedge clk);

		for(int j = 0; j < IC; j++) begin
			data_init_addr = AW'(10 + j*IW*IH);
			weight_init_addr = AW'(1 + j*KSIZE*KSIZE);
			for(int i = 0; i < IH/BUFH; i++) begin
				$display("The %d block compute start", i);
				data_load = 1;
				if (i == 0) data_init_addr_en = 1;
				@(posedge clk);
				data_init_addr_en = 0;
				//wait(blkend == 1);
				@(negedge blkend);
				data_load = 0;
				@(negedge result_valid);
			end
		end

		repeat(1000) @(posedge clk);
		//data_load = 1;
		$stop;
	end


endprogram
