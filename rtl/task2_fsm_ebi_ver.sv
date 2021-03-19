//=====================================================================================
//
// Finite State Machine
// Sourced From Quartus II Sample FSM
//
//		Original Comments:
//		 SystemVerilog state machine implementation that uses enumerated types.
//		 Altera recommends using this coding style to describe state machines in SystemVerilog.
//		 In Quartus II integrated synthesis, the enumerated type
//		 that defines the states for the state machine must be
//		 of an unsigned integer type. If you do not specify the
//		 enumerated type as int unsigned, a signed int type is used by default.
//		 In this case, the Quartus II integrated synthesis synthesizes the design, but
//		 does not infer or optimize the logic as a state machine.
//
// Changed Active LOW reset to Active HIGH reset
//=====================================================================================

module task2_fsm_ebi_ver 
						(	input clk, reset,
							input [7:0] secret_key [2:0],
							input [7:0] q,
							
							output logic [7:0] iterator, out_value,
							output logic wren
						);
									
	logic [7:0] iterator_i, iterator_j, iterator_k, saved_value_i, saved_value_j;		
	logic [1:0] wait_count;	
	parameter WAIT_STATE_AMOUNT = 2;
	parameter END_OF_MSG = 8'hFF;	
	parameter KEY_LENGTH = 3;
	
	wire [7:0] mods;
	assign mods = secret_key[iterator_i%KEY_LENGTH]; // secret_key[i mod keylength]
	
	
	// RAM and ROM
	decrypted_msg RAM2 (.address(/*addr_d*/), .data(/*data_d*/), .wren(/*wren_d*/));

	encrypted_msg ROM (.q(/*q_m*/), .address (/*addr_m*/));

	// LOOP 1 WIRES & REGS:
	logic final_increment;
	
	// Iterator selection
	
	logic [7:0] requested_iterator_main_loop;
	logic request_iterator_main_loop_flag;
	
	logic [7:0] requested_iterator_loop_2;
	logic request_iterator_loop_2_flag; 
	
	mux_one_hot_select #(/*BIT_WIDTH*/ 8, /*INPUT_NUMBER*/ 2) iterator_selector
	(	// Inputs
		.select({request_iterator_loop_2_flag, request_iterator_main_loop_flag}),
		.a('{requested_iterator_loop_2,requested_iterator_main_loop}),
		
		// Outputs 
		.out(iterator)
	
	);
	
	
	// LOOP 2 WIRES & REGS:
	logic request_to_write_loop_2;
	logic [7:0] requested_out_value_loop_2;
	
	logic start_loop_2;
	logic finished_loop_2;
	logic reset_loop_2;
	
task2_swap_ij_fsm loop_2_swap
						(	// Inputs
							.clk(clk),
					   	.reset(reset_loop_2),
							.fsm_start(start_loop_2),
							.q(q), 
							.iterator_i(iterator_i), 
							.iterator_j(iterator_j),
							
							// Outputs
							.iterator(requested_iterator_loop_2), 
							.out_value(requested_out_value_loop_2),       
							.saved_value_i(), 								// optional output for use in loop 3
							.saved_value_j(), 								// optional output for use in loop 3
							.wren(request_to_write_loop_2),
							.fsm_finished(finished_loop_2)
						);
	
	// Defining states
	enum int unsigned { 
		// Loop 1
		START = 0, 
		INITIALIZE_S_ARRAY = 1,
		COMPLETED_S_ARRAY = 2,
		
		// Loop 2
		//ITERATE_LOOP_2 = 3,
		//WAIT_ITERATE_LOOP_2 = 15,
		ITERATE_I_LOOP_2 = 3,
		WAIT_FOR_I_LOOP_2 = 4,
		ITERATE_J_LOOP_2 = 5,
		WAIT_FOR_J_LOOP_2 = 6,
		SWAP_IJ_LOOP_2 = 7,
		COMPLETED_LOOP_2 = 8,
		
		// Loop 3
		ITERATE_LOOP_3 = 9,
		SWAP_IJ_LOOP_3 = 10,
		RETRIEVE_K_LOOP_3 = 11,
		OUTPUT_K_LOOP_3 =12,
		COMPLETED_DECRYPTION = 13
		
	} state, next_state;		
	
	// Defining next_state order
	always_comb begin : next_state_logic 
	next_state = START;
		case(state)
				// Loop 1
				START: 
				begin
					next_state = INITIALIZE_S_ARRAY;
				end 
				
				INITIALIZE_S_ARRAY: 
				begin
					next_state = (iterator_i == END_OF_MSG/* && final_increment == 1*/) ? COMPLETED_S_ARRAY : INITIALIZE_S_ARRAY;
				end 
				
				COMPLETED_S_ARRAY: 
				begin
					//next_state = COMPLETED_S_ARRAY; 
					//next_state = ITERATE_LOOP_2;
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? WAIT_FOR_I_LOOP_2 : COMPLETED_S_ARRAY;
				end 
				
				// Loop 2
				/*
				ITERATE_LOOP_2: 
				begin
					next_state = (iterator_i == END_OF_MSG) ? COMPLETED_LOOP_2 : WAIT_ITERATE_LOOP_2;// SWAP_IJ_LOOP_2;
				end 
				
				WAIT_ITERATE_LOOP_2:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? SWAP_IJ_LOOP_2 : WAIT_ITERATE_LOOP_2;
				end
				*/
				
				ITERATE_I_LOOP_2: 
				begin
					next_state = (iterator_i == END_OF_MSG) ? COMPLETED_LOOP_2 : WAIT_FOR_I_LOOP_2;// SWAP_IJ_LOOP_2;
				end 
				
				WAIT_FOR_I_LOOP_2:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? ITERATE_J_LOOP_2 : WAIT_FOR_I_LOOP_2;
				end
				
				ITERATE_J_LOOP_2:
				begin
					next_state = WAIT_FOR_J_LOOP_2;
				end
				
				WAIT_FOR_J_LOOP_2:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? SWAP_IJ_LOOP_2 : WAIT_FOR_J_LOOP_2;
				end
				
				SWAP_IJ_LOOP_2:
				begin
					next_state = finished_loop_2 ? ITERATE_I_LOOP_2 : SWAP_IJ_LOOP_2;	// Change state once complete, otherwise stay
				end
				
				COMPLETED_LOOP_2: 
				begin
					next_state = COMPLETED_LOOP_2;
					//next_state = ITERATE_LOOP_3;
				end 
				
				// Loop 3
				ITERATE_LOOP_3: 
				begin
					next_state = SWAP_IJ_LOOP_3;
				end 
				
				SWAP_IJ_LOOP_3: 
				begin
					next_state = SWAP_IJ_LOOP_3; // FIX THIS
				end 
				
				RETRIEVE_K_LOOP_3: 
				begin
					next_state = (iterator_k == END_OF_MSG) ? COMPLETED_DECRYPTION : ITERATE_LOOP_3;
				end 
				
				COMPLETED_DECRYPTION: 
				begin
					next_state = COMPLETED_DECRYPTION;
				end 
				
			default: next_state = START;
		endcase
	end
	
	// Defining output values
	always_comb 
	begin 
			case(state)
			   // Loop 1
				START: 
				begin	
					wren <= 0;
				end
				
				INITIALIZE_S_ARRAY: 
				begin	
					wren <= 1;
				end
				
				COMPLETED_S_ARRAY: 
				begin	
					wren <= 1;
				end
				
				// Loop 2
				/*
				ITERATE_LOOP_2:
				begin	
					wren <= 0;
				end	
				
				WAIT_ITERATE_LOOP_2:
				begin	
					wren <= 0;
				end	
				*/
				ITERATE_I_LOOP_2:
				begin	
					wren <= 0;
				end	
				
				WAIT_FOR_I_LOOP_2:
				begin	
					wren <= 0;
				end	
				
				ITERATE_J_LOOP_2:
				begin	
					wren <= 0;
				end	
				
				WAIT_FOR_J_LOOP_2:
				begin	
					wren <= 0;
				end	
				
				SWAP_IJ_LOOP_2:
				begin
					wren <= request_to_write_loop_2;
				end
				
				COMPLETED_LOOP_2:
			   begin	
					wren <= 0;
				end	
				
				// Loop 3
				ITERATE_LOOP_3:
				begin	
					wren <= 0;
				end	
				
				SWAP_IJ_LOOP_3:
				begin
					wren <= request_to_write_loop_2; // FIX THIS
				end
				
				RETRIEVE_K_LOOP_3:
				begin
					wren <= 0;
				end
				
				OUTPUT_K_LOOP_3:
				begin
					wren <= 1;
				end
				
				COMPLETED_DECRYPTION:
				begin
					wren <= 0;
				end
				
				default: // If something goes wrong, default START State value
				begin
					wren <= 0;
				end
			endcase
	end
	
	// Handle resets and updating state to next_state
	always_ff@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			state <= START;
			//iterator <= 8'h00;
			requested_iterator_main_loop <= 8'h00;
			iterator_i <= 8'h00;
			iterator_j <= 8'h00;
			
			request_iterator_main_loop_flag <= 1'b0;
			request_iterator_loop_2_flag <= 1'b0; 
			
			out_value <= 8'h00;
			
			final_increment <= 1'b0;
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				START:
				begin
					//iterator <= 8'h00;
					requested_iterator_main_loop <= 8'h00;
					iterator_i <= 8'h00;
					iterator_j <= 8'h00;
					
					request_iterator_main_loop_flag <= 1'b0;
					request_iterator_loop_2_flag <= 1'b0; 
					
					
					out_value <= 8'h00;
					
					//
					wait_count <= 2'b0;
					
					//
					final_increment <= 1'b0;
					
					// Make sure the swap-ij is on stand-by
					reset_loop_2 <= 1'b1;
					start_loop_2 <= 1'b0;
				end

				INITIALIZE_S_ARRAY: 
				begin
					iterator_i <= iterator_i + 8'h01;
					requested_iterator_main_loop <= iterator_i;
					request_iterator_main_loop_flag <= 1'b1;
					out_value <= iterator_i;
					
					wait_count <= 2'b0;				// only needed for final step
					if(iterator === END_OF_MSG)
						final_increment <= 1'b1;	// there may be a more efficient solution
				end
				
				COMPLETED_S_ARRAY:
				begin
					iterator_i <= 8'h00;
					out_value <= iterator_i;
					requested_iterator_main_loop <= iterator_i;
					request_iterator_main_loop_flag <= 1'b1;
					
					// maybe add first stage of iterate key
					wait_count <= wait_count + 2'b01;
				end
				
				ITERATE_I_LOOP_2:
				begin
					iterator_i <= iterator_i + 8'h01;
					requested_iterator_main_loop <= iterator_i;
					
					request_iterator_main_loop_flag <= 1'b1;
					request_iterator_loop_2_flag <= 1'b0; 
					
					//reset_loop_2 <= 1'b1;
					//start_loop_2 <= 1'b0;
					
					wait_count <= 2'b0;
				end
				
				WAIT_FOR_I_LOOP_2:
				begin
					requested_iterator_main_loop <= iterator_i;
					
					request_iterator_main_loop_flag <= 1'b1;
					request_iterator_loop_2_flag <= 1'b0; 
					
					wait_count <= wait_count + 2'b01;
				end
				
				ITERATE_J_LOOP_2:
				begin
					iterator_j = (iterator_j + q + mods) % 256;	//(secret_key % KEY_LENGTH); // can also be implemented with shift //&?&
					requested_iterator_main_loop <= iterator_i;
					
					request_iterator_main_loop_flag <= 1'b1;
					request_iterator_loop_2_flag <= 1'b0; 
					
					reset_loop_2 <= 1'b1;
					start_loop_2 <= 1'b0;
					
					wait_count <= 2'b0;
				end
				
				WAIT_FOR_J_LOOP_2:
				begin
					request_iterator_main_loop_flag <= 1'b0;
					request_iterator_loop_2_flag <= 1'b1; 
					
					wait_count <= wait_count + 1;
				end
				
			   /*	
				WAIT_ITERATE_LOOP_2:
				begin
					iterator_j <= (iterator_j + q + mods) % 256;	//(secret_key % KEY_LENGTH); // can also be implemented with shift
					requested_iterator_main_loop <= iterator_i;
					
					request_iterator_main_loop_flag <= 1'b0;
					request_iterator_loop_2_flag <= 1'b1; 
					
					reset_loop_2 <= 1'b1;
					start_loop_2 <= 1'b0;
					
					wait_count <= wait_count + 1;
				end
				*/
				
				SWAP_IJ_LOOP_2:
				begin
					//iterator <= requested_iterator_loop_2;				// MUX use assign
					request_iterator_loop_2_flag <= 1'b1; 
					
					out_value <= requested_out_value_loop_2;
					
					reset_loop_2 <= 1'b0;
					start_loop_2 <= 1'b1;
				end

				COMPLETED_DECRYPTION:
				begin
					iterator_i <= 8'h00;
					iterator_j <= 8'h00;
				end
			endcase

		
			state <= next_state;
		end
	end
endmodule