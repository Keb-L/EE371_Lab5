module fir_filter
#(parameter N = 3)
(clock, enable, d, q);

input logic clock, enable;
input logic signed [23:0] d;
output logic signed [23:0] q;

logic signed [23:0] buffer[0:2**N-1];
logic signed [23:0] ret;

// 
int k;
always_comb begin
	buffer[0] = d;
	
//	ret = buffer.sum();
	
	ret = '0;
	for(k=0; k<2**N; k++)
		ret = ret + (buffer[k] >>> N);
end

// D_FF Series
genvar i;
generate
	for(i=0; i<2**N-1; i++) begin : dff_series
		D_FF #(24) dqff_i (buffer[i], buffer[i+1], clock, ~enable);
	end
endgenerate

// Assign output
assign q = enable ? ret : d;

//always_ff @(posedge clock)
//	buffer <= buffer;

endmodule

module fir_filter_testbench();
logic clock, enable;
logic [23:0] d, q, d3;

fir_filter dut (clock, enable, d, q);

parameter CLOCK_PERIOD = 20000;
initial begin
	clock <= 0;
	forever #(CLOCK_PERIOD/2) clock <= ~clock;
end

always_comb
	d3 = d >> 3;

int i;
initial begin
enable = 0;		@(posedge clock);
for (i=0; i<100; i++) begin
	enable = 0; d = 200 + i; @(posedge clock);
end
enable = 0; @(posedge clock);
#100000;
$stop;
end

endmodule