`timescale 1ns/1ns

module task2_TB_ebi_ver;
    logic clk, reset_n; //, fsm_start;

    //logic [9:0] secret_key;
    logic [7:0] q;//, iterator_i, iterator_j;

    logic [7:0] iterator, out_value;
    logic wren;

    parameter logic [7:0] key [2:0]= '{8'h49,8'h02, 8'h00};

    parameter clock_scale = 5'd20;		// for clk
									
	 
	task2_fsm_ebi_ver pass_through_values(
		// Inputs
		.clk(clk),
		.reset(reset_n),
		//.secret_key(key),
		.q(q),
		
		// Outputs
		.iterator(iterator),
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
			//iterator_i <= 8'h00;
            		//iterator_j <= 8'h01;
			//fsm_start <= 1'b1;
			q <= 8'h12;

			#clock_scale;
			
			// COPY I
			//assert(saved_value_i === q) else $error("Problem at 0");
			q <= 8'h34;
			//assert(iterator === iterator_i) else $error("Problem at 0");
			assert(wren === 0) else $error("Problem at 0");

			#clock_scale;

			// COPY J
			//assert(saved_value_i === q) else $error("Problem at 0");
			q <= 8'h56;
			//assert(iterator === iterator_j) else $error("Problem at 0");
			assert(wren === 0) else $error("Problem at 0");

			#clock_scale;

			// SWAP I
    			//assert(out_value === saved_value_i) else $error("Problem at 0");
			q <= 8'h78;
			//assert(iterator === iterator_i) else $error("Problem at 0");
			assert(wren === 1) else $error("Problem at 0");

			#clock_scale;

			// SWAP J
			//assert(out_value === saved_value_j) else $error("Problem at 0");
			q <= 8'h90;
			//assert(iterator === iterator_j) else $error("Problem at 0");
			assert(wren === 1) else $error("Problem at 0");

			#clock_scale;
			
			// FINISH
			//assert(iterator === 8'h00) else $error("Problem at 0");
			assert(wren === 0) else $error("Problem at 0");

			#clock_scale;

			reset_n <= 1'b1;
			//iterator_i <= 8'h05;
            		//iterator_j <= 8'h10;

			#clock_scale;

			reset_n <= 1'b0;

			#clock_scale;
			
			// COPY I
			//assert(saved_value_i === q) else $error("Problem at 0");
			q <= 8'h11;
			//assert(iterator === iterator_i) else $error("Problem at 0");
			assert(wren === 0) else $error("Problem at 0");

			#clock_scale;

			// COPY J
			//assert(saved_value_i === q) else $error("Problem at 0");
			q <= 8'h22;
			//assert(iterator === iterator_j) else $error("Problem at 0");
			assert(wren === 0) else $error("Problem at 0");

			#clock_scale;

			// SWAP I
    			//assert(out_value === saved_value_i) else $error("Problem at 0");
			q <= 8'h33;
			//assert(iterator === iterator_i) else $error("Problem at 0");
			assert(wren === 1) else $error("Problem at 0");

			#clock_scale;

			// SWAP J
			//assert(out_value === saved_value_j) else $error("Problem at 0");
			q <= 8'h44;
			//assert(iterator === iterator_j) else $error("Problem at 0");
			assert(wren === 1) else $error("Problem at 0");

			#clock_scale;
			
			// FINISH
			//assert(iterator === 8'h00) else $error("Problem at 0");
			assert(wren === 0) else $error("Problem at 0");

			#clock_scale;


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