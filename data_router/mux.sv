module mux#(
	parameter DW = 1,
	parameter POY = 3,
	parameter BUFW = 32
)(
	input [DW-1:0] 	idata[POY][BUFW],
	// This bank signal's width is fixed,
	// which means that bank's quantity cannot 
	// be configured more than 4.
	input [1:0]			bank, 
	output[DW-1:0]	odata[BUFW]
);

always@* begin
	for(int i = 0; i < POY; i++) begin
		if (bank == i) odata = idata[i];
		else odata = {DW{1'bx}};
	end
end


endmodule
