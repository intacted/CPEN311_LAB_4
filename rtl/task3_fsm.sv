module task3_fsm
				(
					input clk, reset,
               //input [7:0] secret_key[2:0],
               input logic [7:0] q,
					
               output logic [7:0] iterator, 
					//output logic [7:0] secret_key[2:0],
					output logic [23:0] secret_key,
					output logic [7:0] out_value,
					output logic wren
				);
				
				
	parameter MAX_KEY = 24'hFFFF_FF;
	parameter WAIT_STATE_AMOUNT = 2;
	logic [1:0] wait_count;	

	logic [7:0] key [2:0];
	assign key[2:0] = '{secret_key[7:0],secret_key[15:8],secret_key[23:16]}; //'{secret_key[23:16],secret_key[15:8],secret_key[7:0]};
	
	logic failed_decrypt, done_decrypt, reset_decryption, start_decryption;
							
	task2_fsm decryption_module(
		// Inputs
		.clk(clk),
		.reset(reset_decryption),
		.start_FSM_1(start_decryption),
		.secret_key(key),
		.q(q),
		
		// Outputs
		.iterator(iterator),
		.out_value(out_value),
		.wren(wren),
		.failed_decrypt(failed_decrypt),
		.done_decrypt(done_decrypt)
	);
	
	/*
	mux_one_hot_select #(BIT_WIDTH 8, INPUT_NUMBER 2) iterator_selector
	(	// Inputs
		.select({request_iterator_loop_2_flag, request_iterator_main_loop_flag}),
		.a('{requested_iterator_loop_2,requested_iterator_main_loop}),
		
		// Outputs 
		.out(iterator)
	);
	*/
				 	 
	// Defining states
	enum int unsigned { 
		START = 1,
		ITERATE_KEY = 2,
		WAIT_ITERATE = 5,
		DECRYPT_KEY = 3,
		FINISH = 4
	} state, next_state;		
	
	// Defining next_state order
	always_comb begin : next_state_logic 
	next_state = START;
		case(state)
				START:
				begin
					// Makes sure that all zeros is used as a key
					next_state = WAIT_ITERATE;
				end
					
				ITERATE_KEY:
				begin
					next_state = WAIT_ITERATE;
				end
				
				WAIT_ITERATE:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? DECRYPT_KEY : WAIT_ITERATE;
				end
				
				DECRYPT_KEY:
				begin
					//next_state = /*finished ? COMPLETED_DECRYPTION :*/ (secret_key == MAX_KEY) ? FINISH : ITERATE_KEY;
					
					//next_state = (failed_decrypt === 1 || done_decrypt == 1) ? ( (secret_key === MAX_KEY) ? FINISH : ITERATE_KEY ) : DECRYPT_KEY;
					if (done_decrypt === 1)
						next_state = FINISH;
					else if (failed_decrypt === 1)// || done_decrypt == 1)
						next_state = (secret_key === MAX_KEY) ? FINISH : ITERATE_KEY;
					else
						next_state = DECRYPT_KEY;
				end
				
				FINISH: 
				begin
					next_state = FINISH;
				end 
				
			default: next_state = START;
		endcase
	end
		
	// Handle resets and updating state to next_state
	always_ff@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			state <= START;

			secret_key <= 24'h000_000;			// maybe change formatting of secret_key
			
			start_decryption <= 1'b0;
			reset_decryption <= 1'b1;
			
			wait_count <= 2'b0;
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				START:
				begin
					secret_key <= 24'h000_000;			// maybe change formatting of secret_key

					start_decryption <= 1'b0;
					reset_decryption <= 1'b1;
					
					wait_count <= 2'b0;
				end
				
				ITERATE_KEY:
				begin
					secret_key <= secret_key + 1;
					
					start_decryption <= 1'b0;
					reset_decryption <= 1'b1;
					
					wait_count <= 2'b0;
				end
				
				WAIT_ITERATE:
				begin
					wait_count <= wait_count + 2'b01;
				end
				
				DECRYPT_KEY:
				begin
					// start fsm1, which will start fsm2 on it's own
					start_decryption <= 1'b1;
					reset_decryption <= 1'b0;
				end
				
				FINISH:
				begin
					//
				end
			endcase

		
			state <= next_state;
		end
	end
	
endmodule