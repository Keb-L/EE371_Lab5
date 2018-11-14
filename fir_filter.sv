module fir_filter
#(parameter N = 7)
(clock, enable, d, q);

input logic clock, enable;
input logic [23:0] d;
output logic [23:0] q;

logic [23:0] buffer [0:7];
logic [23:0] ret;

// 
int k;
always_comb begin
	buffer[0] = d >>> 3;
	
	ret = buffer.sum();
//	ret = '0;
//	for(k=0; k<N; i++) begin
//		ret = signal[i];
//	end
end

// D_FF Series
genvar i;
generate
	for(i=0; i<N; i++) begin : dff_series
		D_FF #(24) dqff_i (buffer[i], buffer[i+1], clock, ~enable);
	end
endgenerate

// Assign output
assign q = (enable) ? ret : d;


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