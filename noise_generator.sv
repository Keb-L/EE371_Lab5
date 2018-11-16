module noise_generator
(
	clock, enable, q
);

input logic clock, enable;
output logic signed [23:0] q;

logic [2:0] counter;

always_ff @(posedge clock)
	if(enable)
		counter <= counter + 1'b1;
		
assign q = enable ? {{10{counter[2]}}, counter, 11'd0} : '0;
endmodule