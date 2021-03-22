module task3_bonus_fsm
				(
					input clk, reset,
					
					output logic [23:0] HEX_LED_VALUE,
					output logic [5:0] status
				);
				
				
	parameter MAX_KEY = 24'hFFFF_FF;
	parameter WAIT_STATE_AMOUNT = 2;
	logic [1:0] wait_count;	
	
	// Decryption Module 1
	logic [7:0] iterator1, q1, out_value1;
	logic wren1;
	
	logic [23:0] secret_key; //secret_key1;
	//assign secret_key1 = secret_key;
	
	logic [7:0] key1 [2:0];
	//assign key1[2:0] = '{secret_key1[7:0],secret_key1[15:8],secret_key1[23:16]}; 
	assign key1[2:0] = '{secret_key[7:0],secret_key[15:8],secret_key[23:16]};
	
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
	
	
	s_memory output_to_S2(
		.address(iterator2),
		.clock(clk),         
		.data(out_value2),		
		.wren(wren2),
		.q(q2)
	);
	
	
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
	
	
	s_memory output_to_S3(
		.address(iterator3),
		.clock(clk),         
		.data(out_value3),		
		.wren(wren3),
		.q(q3)
	);
	
	
	// Decryption Module 4
	logic [7:0] iterator4, q4, out_value4;
	logic wren4;
	
	logic [23:0] secret_key4;
	assign secret_key4 = secret_key + 24'h0000_03;
	
	logic [7:0] key4 [2:0];
	assign key4[2:0] = '{secret_key4[7:0],secret_key4[15:8],secret_key4[23:16]}; 
	
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
	
	
	s_memory output_to_S4(
		.address(iterator4),
		.clock(clk),         
		.data(out_value4),		
		.wren(wren4),
		.q(q4)
	);
	

				 	 
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
					if (
							   (done_decrypt1 === 1 && !(failed_decrypt1)) 
							|| (done_decrypt2 === 1 && !(failed_decrypt2)) 
							|| (done_decrypt3 === 1 && !(failed_decrypt3)) 
							|| (done_decrypt4 === 1 && !(failed_decrypt4))
						) 
					begin
						next_state = FINISH;
					end
					
					else if (failed_decrypt1 === 1 && failed_decrypt2 === 1 && failed_decrypt3 === 1 && failed_decrypt4 === 1)
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

			secret_key <= 24'h000_000;	
			HEX_LED_VALUE <= 24'h000_000;
			
			start_decryption1 <= 1'b0;
			reset_decryption1 <= 1'b1;
			
			wait_count <= 2'b0;
			
			status <= 6'b000000;	// operating
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				START:
				begin
					secret_key <= 24'h000_000;
					HEX_LED_VALUE <= 24'h000_000;			

					start_decryption1 <= 1'b0;
					reset_decryption1 <= 1'b1;
					
					start_decryption2 <= 1'b0;
					reset_decryption2 <= 1'b1;
					
					start_decryption3 <= 1'b0;
					reset_decryption3 <= 1'b1;
					
					start_decryption4 <= 1'b0;
					reset_decryption4 <= 1'b1;
					
					wait_count <= 2'b0;
				end
				
				ITERATE_KEY:
				begin
					secret_key <= secret_key + 24'h000_004;
					HEX_LED_VALUE <= secret_key + 24'h000_004;
					
					start_decryption1 <= 1'b0;
					reset_decryption1 <= 1'b1;
					
					start_decryption2 <= 1'b0;
					reset_decryption2 <= 1'b1;
					
					start_decryption3 <= 1'b0;
					reset_decryption3 <= 1'b1;
					
					start_decryption4 <= 1'b0;
					reset_decryption4 <= 1'b1;
					
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
					
					start_decryption2 <= 1'b1;
					reset_decryption2 <= 1'b0;
					
					start_decryption3 <= 1'b1;
					reset_decryption3 <= 1'b0;
					
					start_decryption4 <= 1'b1;
					reset_decryption4 <= 1'b0;
				end
				
				FINISH:
				begin
					if(failed_decrypt1 && failed_decrypt2 && failed_decrypt3 && failed_decrypt4)
						status <= 6'bxxxx_01;
					else
						status <= 6'bxxxx_10;
				
					
					// needs priority driver,
					if (done_decrypt1 && !(failed_decrypt1))
					begin
						HEX_LED_VALUE <= secret_key;
						status <= 6'b0001_xx;
					end		
					else if (done_decrypt2 && !(failed_decrypt2))
					begin
						HEX_LED_VALUE <= secret_key2;
						status <= 6'b0010_xx;
					end
					else if (done_decrypt3 && !(failed_decrypt3))
					begin
						HEX_LED_VALUE <= secret_key3;
						status <= 6'b0100_xx;
					end
					else if (done_decrypt4 && !(failed_decrypt4))
					begin
						HEX_LED_VALUE <= secret_key4;
						status <= 6'b1000_xx;
					end
				end
			endcase

		
			state <= next_state;
		end
	end
	
endmodule