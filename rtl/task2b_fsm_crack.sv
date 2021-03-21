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

module task2b_fsm
						(	input clk, reset,
							input [7:0] q,
							input finish_FSM_1,
							
							output logic [7:0] iterator, out_value,
							output logic wren, failed_decrypt, done_decrypt
						);
									
	logic [7:0] iterator_i, iterator_j, iterator_k, saved_value_i, saved_value_j;		
	logic [1:0] wait_count;	
	parameter WAIT_STATE_AMOUNT = 2;
	parameter END_OF_MSG = 6'd31;	
	parameter KEY_LENGTH = 3;
	
	// RAM and ROM
	logic [7:0] f, f_iterator; 
	assign f_iterator = saved_value_i + saved_value_j;
	
	logic [7:0] data_d, q_m;
	logic wren_d;
		
	decrypted_msg RAM2 (.q(), .address(iterator_k), .data(data_d), .wren(wren_d), .clock(clk));

	encrypted_msg ROM (.q(q_m), .address(iterator_k), .clock(clk));

	// Iterator selection
	logic [7:0] requested_iterator_main_loop;
	logic [7:0] requested_iterator_swap;
	
	logic select_swap_iterator;
	
	assign iterator = select_swap_iterator ? requested_iterator_swap : requested_iterator_main_loop;
	
	// SWAP WIRES & REGS:
	logic start_swap;
	logic finished_swap;
	
task2_swap_ij_fsm swap_fsm3
						(	// Inputs
							.clk(clk),
					   	.reset(!start_swap),
							.fsm_start(start_swap),
							.q(q), 
							.iterator_i(iterator_i), 
							.iterator_j(iterator_j),
							
							// Outputs
							.iterator(requested_iterator_swap), 
							.out_value(out_value),       
							.saved_value_i(saved_value_i), 						// optional output for use in loop 3
							.saved_value_j(saved_value_j), 						// optional output for use in loop 3
							.wren(wren),
							.fsm_finished(finished_swap)
						);
						
	// Defining states
	enum int unsigned { 
		// Loop 3
		START = 1,
		ITERATE_I = 2,
		WAIT_FOR_I = 3,
		ITERATE_J = 4,
		WAIT_FOR_J = 5,
		SWAP_IJ = 6,
		RETRIEVE_K = 7,
		OUTPUT_K = 8,
		ITERATE_K = 9,
		COMPLETED_DECRYPTION = 10
	} state, next_state;		
	
	// Defining next_state order
	always_comb begin : next_state_logic 
	next_state = START;
		case(state)
				START:
				begin
					next_state = finish_FSM_1 ? ITERATE_I : START;
				end
					
				ITERATE_I:
				begin
					next_state = WAIT_FOR_I;
				end
				
				WAIT_FOR_I:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? ITERATE_J : WAIT_FOR_I;
				end
				
				ITERATE_J:
				begin
					next_state = WAIT_FOR_J;
				end
				
				WAIT_FOR_J:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? SWAP_IJ : WAIT_FOR_J;
				end
				
				SWAP_IJ: 
				begin
					next_state = finished_swap ? RETRIEVE_K : SWAP_IJ; 
				end 
				
				RETRIEVE_K: 
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? OUTPUT_K : RETRIEVE_K;
				end 
				
				OUTPUT_K:
				begin
					next_state = ITERATE_K;
				end
				
				ITERATE_K:
				begin
					next_state = (iterator_k == END_OF_MSG) ? COMPLETED_DECRYPTION : ITERATE_I;
				end
				
				COMPLETED_DECRYPTION: 
				begin
					next_state = COMPLETED_DECRYPTION;
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
			requested_iterator_main_loop <= 8'h00;
			iterator_i <= 8'h00;
			iterator_j <= 8'h00;
			
			select_swap_iterator <= 1'b0;
			
			data_d <= 8'h00;
			
			failed_decrypt <= 0;
			done_decrypt <= 0;
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				START:
				begin
					requested_iterator_main_loop <= 8'h00;
					iterator_i <= 8'h00;
					iterator_j <= 8'h00;
					iterator_k <= 8'h00;

					//
					select_swap_iterator <= 1'b0;
					
					//
					wait_count <= 2'b0;
								
					// Make sure the swap-ij is on stand-by
					start_swap <= 1'b0;
					
					data_d <= 8'h00;
				end
				
				ITERATE_I:
				begin
					requested_iterator_main_loop <= iterator_i;
					iterator_i <= iterator_i + 1;
					
					select_swap_iterator <= 1'b0;
				
					wait_count <= 2'b0;	
				end
				
				WAIT_FOR_I:
				begin
					requested_iterator_main_loop <= iterator_i;
					wait_count <= wait_count + 2'b01;
				end
				
				ITERATE_J:
				begin
					iterator_j <= iterator_j + q;
					
					wait_count <= 2'b0;
				end
				
				WAIT_FOR_J:
				begin
					wait_count <= wait_count + 2'b01;
					
					select_swap_iterator <= 1'b1;     // double check this
					
					start_swap <= 1'b0;
				end
				
				SWAP_IJ:
				begin
					select_swap_iterator <= 1'b1;
					
					start_swap <= 1'b1;
					
					wait_count <= 2'b0;
				end
				
				RETRIEVE_K:
				begin
					requested_iterator_main_loop <= f_iterator;
					
					select_swap_iterator <= 1'b0;
					
					start_swap <= 1'b1;
					
					wren_d <= 1'b0;
					
					wait_count <= wait_count + 2'b01;
				end
				
				OUTPUT_K:
				begin
					start_swap <= 1'b1;
					
					wren_d <= 1'b1;
					
					data_d <= q ^ q_m;
					
					//if((data_d < 97 || data_d > 8'd122) && !(data_d === 8'd32))
					//	failed_decrypt <= 1;
				end

				ITERATE_K:
				begin
					iterator_k <= iterator_k + 1;
					
					start_swap <= 1'b0;
					
					wren_d <= 1'b0;						// double check this
					
					if((data_d < 97 || data_d > 8'd122) && !(data_d === 8'd32))
						failed_decrypt <= 1;
				end
				
				COMPLETED_DECRYPTION:
				begin
					iterator_i <= 8'h00;
					iterator_j <= 8'h00;
					
					wren_d <= 1'b0;
					
					done_decrypt <= 1;
				end

			endcase

		
			state <= next_state;
		end
	end
endmodule