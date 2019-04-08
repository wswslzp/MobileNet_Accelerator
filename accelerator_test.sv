program accelerator_test #(
	parameter
	AW = 32,
	IC = 64
)(
	input logic 							clk,
	input logic							rst_n,

	// from accelerator
	output logic [31:0] 				comp_cmd,
	output logic [AW-1:0]			data_init_addr_in,
	output logic [AW-1:0]			weight_init_addr_in,
	input logic 							done
	// from output buffer
	
);

event reset_up;

initial 
forever begin
	wait(rst_n == 0);
	comp_cmd = 0;
	data_init_addr_in = 0;
	weight_init_addr_in = 0;
	wait(rst_n == 1);
	repeat(3) @(posedge clk);
	->reset_up;
end

initial 
begin
	@(reset_up);
	for(int i = 0; i < 10; i++) begin
		data_init_addr_in = AW'(i*10+1);
		weight_init_addr_in = AW'(i+1);
		comp_cmd = {1'b1, 3'b000, 28'(IC)};//dwc, ic=64
		@(posedge clk) comp_cmd[31] = 0;
		@(negedge done);
	end
	$stop;
end

endprogram
