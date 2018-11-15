module fir_filter_fifo
#(
	parameter N=8
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



fifo #(.DATA_WIDTH(24), .ADDR_WIDTH(N)) fir (.clk(clock), .reset, .rd, .wr, 
		.w_data(fifo_in), .empty, .full, .r_data(fifo_out));

D_FF #(24) flipflop (.d(accm_d), .q(accm_q), .clk(clock), .reset);
		
always_comb begin
	// Read when FIFO is full and filter is enabled
	rd = (enable & full) ? 1'b1 : 1'b0;
	
	// Write when filter is enabled
	wr = (enable) ? 1'b1 : 1'b0;
	
	// Compute next sample
	fifo_in = d >>> N;
	
	// Compute filter output
	fifo_inv = full ? fifo_out : '0; // Only read the fifo rd output when full
	accm_d = fifo_in - fifo_inv + accm_q;
end

assign q = accm_d;

endmodule 