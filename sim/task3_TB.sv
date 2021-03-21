`timescale 1ns/1ns

module task3_TB;
    logic clk, reset_n; //, fsm_start;

    //logic [9:0] secret_key;
    logic [7:0] q;//, iterator_i, iterator_j;

    logic [7:0] iterator, out_value;
    logic wren;

    parameter logic [7:0] key [2:0]= '{8'h49,8'h02, 8'h00};

    parameter clock_scale = 5'd20;		// for clk
									
	logic [23:0] secret_key;
	
	task3_fsm pass_through_values(
		// Inputs
		.clk(clk),
		.reset(reset_n),
		//.secret_key(key),
		.q(q),
		
		// Outputs
		.iterator(iterator),
		.secret_key(secret_key),
		.out_value(out_value),
		.wren(wren)
	);

	 
	RAM output_to_S(
		.address(iterator),
		.clock(clk),         // double check if this is the correct clock
		.data(out_value),		// figure out what this should be
		.wren(wren),
		.q(q)
	);

	initial
		begin
			reset_n <= 1'b0;


			/*forever
			begin
				// forever loop for testing
			end*/
		end
	
	always
		begin
			clk <=1; #(clock_scale/2);
			clk <=0; #(clock_scale/2);
		end

endmodule