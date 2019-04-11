module shit #(
	parameter
	type T = reg
) (
	input clk,
	input rst_n,
	output data
);
	function automatic logic function_name (parameter);
		
	endfunction
endmodule

interface shit #(
	parameter
	type T
)(
	input clk
);
	task automatic logic[31:0] xp (input a);
		begin :xp1
			fork :statement
				
			join :statement
		end :xp1
	endtask
endinterface
