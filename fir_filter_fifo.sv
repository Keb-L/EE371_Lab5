module fir_filter_fifo
#(
		parameter n=8
)
(clock, enable, d, q, reset);

input logic clock, enable, reset;
input logic [23:0] d;
output logic [23:0] q;

logic [23:0] sample, r_data, invert;
logic [23:0] filter_out;
logic empty, full;
logic [2:0] i;

fifo #(.DATA_WIDTH(24), .ADDR_WIDTH(n)) fir (.clk(clock), .reset, .rd(1'b1), .wr(1'b1), 
		.w_data(sample), .empty, .full, .r_data);

		
always_comb begin
	sample = d >>> n;
	invert = r_data * -1;
end

logic [23:0] temp_q;
D_FF #(24) flipflop (.d(sample), .q(temp_q), .clk(clock), .reset);

always_ff @(posedge clock) begin
	filter_out <= sample + invert + temp_q;
end


assign q = filter_out;

endmodule 