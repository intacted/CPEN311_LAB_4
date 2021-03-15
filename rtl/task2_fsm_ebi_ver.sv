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
							//input [7:0] secret_key [2:0],
							input [7:0] q,
							
							output logic [7:0] iterator, out_value,
							output logic wren
						);
						
	parameter logic [7:0] secret_key [2:0]= '{8'h49,8'h02, 8'h00}; 	//temp	
			
	logic [7:0] iterator_i, iterator_j, iterator_k, saved_value_i, saved_value_j;				
	parameter END_OF_MSG = 8'hFF;	
	parameter KEY_LENGTH = 3;
	
	wire [7:0] mods;
	assign mods= secret_key[iterator%KEY_LENGTH]; // secret_key[i mod keylength]

	
	// LOOP 2 WIRES and REGS:
	logic request_to_write_loop_2;
	logic requested_iterator_loop_2;
	logic requested_out_value_loop_2;
	
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
		ITERATE_LOOP_2 = 3,
		SWAP_IJ_LOOP_2 = 4,
		COMPLETED_LOOP_2 = 7,
		
		// Loop 3
		ITERATE_LOOP_3 = 8,
		SWAP_IJ_LOOP_3 = 9,
		RETRIEVE_K_LOOP_3 = 12,
		OUTPUT_K_LOOP_3 =13,
		COMPLETED_DECRYPTION = 14
		
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
					next_state = (iterator_i == END_OF_MSG) ? COMPLETED_S_ARRAY : INITIALIZE_S_ARRAY;
				end 
				
				COMPLETED_S_ARRAY: 
				begin
					next_state = ITERATE_LOOP_2;
				end 
				
				// Loop 2
				ITERATE_LOOP_2: 
				begin
					next_state = (iterator_i == END_OF_MSG) ? COMPLETED_LOOP_2 : SWAP_IJ_LOOP_2;
				end 
				
				SWAP_IJ_LOOP_2:
				begin
					next_state = finished_loop_2 ? COMPLETED_LOOP_2 : ITERATE_LOOP_2;
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
					wren <= 0;
				end
				
				// Loop 2
				ITERATE_LOOP_2:
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
			iterator <= 8'h00;
			iterator_i <= 8'h00;
			iterator_j <= 8'h00;
			
			out_value <= 8'h00;
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				START:
				begin
					iterator <= 8'h00;
					iterator_i <= 8'h00;
					iterator_j <= 8'h00;
					
					out_value <= 8'h00;
				end

				INITIALIZE_S_ARRAY: 
				begin
					iterator_i <= iterator_i + 8'h01;
					iterator <= iterator_i;
					out_value <= iterator;
				end
				
				COMPLETED_S_ARRAY:
				begin
					iterator_i <= 8'h00;
					iterator <= iterator_i;
					// maybe add first stage of iterate key
				end
				
				ITERATE_LOOP_2:
				begin
					iterator_j <= iterator_j + q + mods;	//(secret_key % KEY_LENGTH);
					iterator_i <= iterator_i + 1;
					iterator <= iterator_i;
					
					reset_loop_2 <= 1'b1;
					start_loop_2 <= 1'b0;
				end
				SWAP_IJ_LOOP_2:
				begin
					iterator <= requested_iterator_loop_2;
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