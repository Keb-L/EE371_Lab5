module fir_filter(clock, enable, d, q);

input logic clock, enable;
input logic [23:0] d;
output logic [23:0] q;

logic [23:0] signal [0:7];
logic [2:0] write_ptr;

logic [23:0] filter_out;

logic [2:0] i;
always_comb begin	
	filter_out = '0;  // Reset accumulator
	for(i=0; i<7; i++)  // Accumulate
		filter_out = filter_out + (signal[write_ptr-i] >>> 3);
end

assign q = filter_out;

always_ff @(posedge clock) begin
	if(~enable) begin
		write_ptr <= 3'd0;
		signal <= '{default:0};
	end
	else begin
		write_ptr <= write_ptr + 1'b1;
		signal[write_ptr] = d; // Add current sample
	end
end

endmodule

module fir_filter_testbench();
logic clock, enable;
logic [23:0] d, q;

fir_filter dut (clock, enable, d, q);

parameter CLOCK_PERIOD = 20000;
initial begin
	clock <= 0;
	forever #(CLOCK_PERIOD/2) clock <= ~clock;
end

int i;
initial begin
enable = 0;		@(posedge clock);
for (i=0; i<100; i++) begin
	enable = 1; d = 200 + i; @(posedge clock);
end
enable = 0; @(posedge clock);
#100000;
$stop;
end

endmodule