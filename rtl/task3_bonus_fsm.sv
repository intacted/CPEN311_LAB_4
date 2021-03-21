module task3_bonus_fsm
				(
					input clk, reset,
					
					output logic [23:0] secret_key
				);
				
				
	parameter MAX_KEY = 24'hFFFF_FF;
	parameter WAIT_STATE_AMOUNT = 2;
	logic [1:0] wait_count;	

	// Decryption Module 1
	logic [7:0] iterator1, q1, out_value1;
	logic wren1;
	
	logic [7:0] key1 [2:0];
	assign key1[2:0] = '{secret_key[7:0],secret_key[15:8],secret_key[23:16]}; //'{secret_key[23:16],secret_key[15:8],secret_key[7:0]};
	
	logic failed_decrypt1, done_decrypt1, reset_decryption1, start_decryption1;
							
	task2_fsm decryption_module1(
		// Inputs
		.clk(clk),
		.reset(reset_decryption1),
		.start_FSM_1(start_decryption1),
		.secret_key(key1),
		.q(q1),
		
		// Outputs
		.iterator(iterator1),
		.out_value(out_value1),
		.wren(wren1),
		.failed_decrypt(failed_decrypt1),
		.done_decrypt(done_decrypt1)
	);
	
	s_memory output_to_S1(
		.address(iterator1),
		.clock(clk),         
		.data(out_value1),		
		.wren(wren1),
		.q(q1)
	);
	
	// Decryption Module 2
	logic [7:0] iterator2, q2, out_value2;
	logic wren2;
	
	logic [23:0] secret_key2;
	assign secret_key2 = secret_key + 24'h0000_01;
	
	logic [7:0] key2 [2:0];
	assign key2[2:0] = '{secret_key2[7:0],secret_key2[15:8],secret_key2[23:16]}; 
	
	logic failed_decrypt2, done_decrypt2, reset_decryption2, start_decryption2;
							
	task2_fsm decryption_module2(
		// Inputs
		.clk(clk),
		.reset(reset_decryption2),
		.start_FSM_1(start_decryption2),
		.secret_key(key2),
		.q(q2),
		
		// Outputs
		.iterator(iterator2),
		.out_value(out_value2),
		.wren(wren2),
		.failed_decrypt(failed_decrypt2),
		.done_decrypt(done_decrypt2)
	);
	
	/*
	s_memory output_to_S2(
		.address(iterator2),
		.clock(clk),         
		.data(out_value2),		
		.wren(wren2),
		.q(q2)
	);
	*/
	
	// Decryption Module 3
	logic [7:0] iterator3, q3, out_value3;
	logic wren3;
	
	logic [23:0] secret_key3;
	assign secret_key3 = secret_key + 24'h0000_02;
	
	logic [7:0] key3 [2:0];
	assign key3[2:0] = '{secret_key3[7:0],secret_key3[15:8],secret_key3[23:16]}; 
	
	logic failed_decrypt3, done_decrypt3, reset_decryption3, start_decryption3;
							
	task2_fsm decryption_module3(
		// Inputs
		.clk(clk),
		.reset(reset_decryption3),
		.start_FSM_1(start_decryption3),
		.secret_key(key3),
		.q(q3),
		
		// Outputs
		.iterator(iterator3),
		.out_value(out_value3),
		.wren(wren3),
		.failed_decrypt(failed_decrypt3),
		.done_decrypt(done_decrypt3)
	);
	
	/*
	s_memory output_to_S3(
		.address(iterator3),
		.clock(clk),         
		.data(out_value3),		
		.wren(wren3),
		.q(q3)
	);
	*/
	
	// Decryption Module 4
	logic [7:0] iterator4, q4, out_value4;
	logic wren4;
	
	logic [23:0] secret_key4;
	assign secret_key4 = secret_key + 24'h0000_03;
	
	logic [7:0] key4 [2:0];
	assign key4[2:0] = '{secret_key3[7:0],secret_key3[15:8],secret_key3[23:16]}; 
	
	logic failed_decrypt4, done_decrypt4, reset_decryption4, start_decryption4;
							
	task2_fsm decryption_module4(
		// Inputs
		.clk(clk),
		.reset(reset_decryption4),
		.start_FSM_1(start_decryption4),
		.secret_key(key4),
		.q(q4),
		
		// Outputs
		.iterator(iterator4),
		.out_value(out_value4),
		.wren(wren4),
		.failed_decrypt(failed_decrypt4),
		.done_decrypt(done_decrypt4)
	);
	
	/*
	s_memory output_to_S4(
		.address(iterator4),
		.clock(clk),         
		.data(out_value4),		
		.wren(wren4),
		.q(q4)
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
					if (done_decrypt1 === 1)
						next_state = FINISH;
					else if (failed_decrypt1 === 1)// || done_decrypt == 1)
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
			
			start_decryption1 <= 1'b0;
			reset_decryption1 <= 1'b1;
			
			wait_count <= 2'b0;
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				START:
				begin
					secret_key <= 24'h000_000;			// maybe change formatting of secret_key

					start_decryption1 <= 1'b0;
					reset_decryption1 <= 1'b1;
					
					wait_count <= 2'b0;
				end
				
				ITERATE_KEY:
				begin
					secret_key <= secret_key + 1;
					
					start_decryption1 <= 1'b0;
					reset_decryption1 <= 1'b1;
					
					wait_count <= 2'b0;
				end
				
				WAIT_ITERATE:
				begin
					wait_count <= wait_count + 2'b01;
				end
				
				DECRYPT_KEY:
				begin
					// start fsm1, which will start fsm2 on it's own
					start_decryption1 <= 1'b1;
					reset_decryption1 <= 1'b0;
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