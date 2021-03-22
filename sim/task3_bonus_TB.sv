`timescale 1ns/1ns

module task3_bonus_TB;
    logic clk, reset_n; //, fsm_start;

	logic [5:0] completion_status;

    parameter logic [7:0] key [2:0]= '{8'h49,8'h02, 8'h00};

    parameter clock_scale = 5'd20;		// for clk
									
	logic [23:0] secret_key;
	
	task3_bonus_fsm pass_through_values(
		// Inputs
		.clk(clk),
		.reset(reset_n),

		// Outputs
		.HEX_LED_VALUE(secret_key),
		.status(completion_status)
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