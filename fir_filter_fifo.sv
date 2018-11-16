module fir_filter_fifo
#(
	parameter N=8,	//Size of the fifo 
	parameter M=3	//2**M = N
)
(
	clock, enable, d, q, reset
);

input logic clock, enable, reset;
input logic [23:0] d;
output logic [23:0] q;

// FIFO variables
logic [23:0] fifo_in, fifo_out;
logic [23:0] fifo_inv;
logic empty, full;
logic rd, wr;

// Accumulator variables
logic [23:0] accm_d, accm_q;
// Filter Var
logic [23:0] filter_out;

fifo #(.DATA_WIDTH(24), .ADDR_WIDTH(M)) fir (.clk(clock), .reset, .rd, .wr, 
		.w_data(fifo_in), .empty, .full, .r_data(fifo_out));

D_FF #(24) flipflop (.d(accm_d), .q(accm_q), .clk(clock), .reset);
		
always_comb begin
	// Read when FIFO is full and filter is enabled
	rd = (enable & full) ? 1'b1 : 1'b0;
	
	// Write when filter is enabled
	wr = (enable) ? 1'b1 : 1'b0;
	
	// Compute next sample
	fifo_in = d >>> M;
	
	// Compute filter output
	fifo_inv = full ? fifo_out : '0; // Only read the fifo rd output when full
	accm_d = fifo_in - fifo_inv + accm_q;
end

assign q = accm_d;

endmodule 

module fir_filter_fifo_testbench();
	logic clock, enable, reset;
	logic [23:0] d;
	logic [23:0] q;
	
	fir_filter_fifo #(8, 3) dut (clock, enable, d, q, reset);
	
	parameter CLOCK_PERIOD = 20000;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock;
	end
	int i;
	initial begin
		enable = 0;
		reset = 1; @(posedge clock);
		reset = 0;
		for (i = 0; i < 250; i++) begin
			enable = 1; d = 200 + i; @(posedge clock);
		end
		$stop;
	end
	
endmodule 