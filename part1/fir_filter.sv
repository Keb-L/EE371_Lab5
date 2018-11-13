module fir_filter(clock, enable, d, q);

input logic clock, enable;
input logic [23:0] d;
output logic [23:0] q;

logic [23:0] signal [0:6];
logic [2:0] write_ptr;

logic [23:0] filter_out;

int i;
always_comb begin
	signal[write_ptr] = d; // Add current sample
	
	filter_out = '0; // Reset accumulator
	for(i=0; i<7; i++) // Accumulate
		filter_out = filter_out + (signal[write_ptr-i] >>> 3);
end

assign q = filter_out;

always_ff @(posedge clock)
	if(~enable)
		write_ptr <= 3'd0;
	else
		write_ptr <= write_ptr + 1'b1;


endmodule