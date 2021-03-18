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

module task2_swap_ij_fsm 
						(	input clk, reset, fsm_start,
							input [7:0] q, iterator_i, iterator_j,
							
							output logic [7:0] iterator, out_value,
							output logic [7:0] saved_value_i, saved_value_j, // optional outputs for use in loop 3
							output logic wren, fsm_finished
						);
					
	parameter END_OF_MSG = 8'hFF;	
	parameter KEY_LENGTH = 3;
	
	parameter WAIT_STATE_AMOUNT = 3;
	logic [1:0] wait_count;
	
	// Defining states
	enum int unsigned { 
		IDLE = 0, 
		COPY_I = 1,
		COPY_J = 2,
		SWAP_I= 3,
		SWAP_J = 4,
		FINISH = 5,

		START = 11,
		WAIT_START = 6,
		WAIT_COPY_I = 7,
		WAIT_COPY_J = 8,
		WAIT_SWAP_I = 9,
		WAIT_SWAP_J = 10			
	} state, next_state;		
	
	// Defining next_state order
	always_comb begin : next_state_logic 
	next_state = IDLE;
		case(state)
				IDLE: 
				begin
					next_state = fsm_start ? START : IDLE;
				end 
				START:
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? WAIT_START : START;
				end
				WAIT_START:
				begin
					next_state = COPY_I;
				end
				
				COPY_I: 
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? WAIT_COPY_I : COPY_I;
				end 
				WAIT_COPY_I:
				begin
					next_state = COPY_J;
				end
				
				COPY_J: 
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? WAIT_COPY_J : COPY_J;
				end 
				WAIT_COPY_J:
				begin
					next_state = SWAP_I;
				end
				
				SWAP_I: 
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? WAIT_SWAP_I : SWAP_I;
				end 
				WAIT_SWAP_I:
				begin
					next_state = SWAP_J;
				end
				
				SWAP_J: 
				begin
					next_state = (wait_count === WAIT_STATE_AMOUNT) ? WAIT_SWAP_J : SWAP_J;
				end 
				WAIT_SWAP_J: 
				begin
					next_state = FINISH;
				end 
		
				FINISH: 
				begin
					next_state = FINISH;
				end 
						
			default: next_state = IDLE;
		endcase
	end
	

	// Handle resets and updating state to next_state
	always_ff@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			state <= IDLE;

			// May be redundant
			saved_value_i <= 8'h00;
			saved_value_j <= 8'h00;
			out_value <= 8'h00;

			fsm_finished <= 0;
			wren <= 0;
			wait_count <= 2'b0;
			
			iterator <= 8'h00;
		end
		
		// If not resetting, normal operation
		else
		begin
			case(state)
				IDLE:
				begin
					saved_value_i <= 8'h00;
					saved_value_j <= 8'h00;
					out_value <= 8'h00;

					fsm_finished <= 0;
					wren <= 0;
					wait_count <= 2'b0;
					
					iterator <= 8'h00;
				end
				START:
				begin
					wait_count <= wait_count + 1;
				end
				WAIT_START:
				begin
					wren <= 0;
					wait_count <= 2'b0;			// may be redundant
				end
				
				COPY_I:
				begin
					saved_value_i <= q;
					iterator <= iterator_i;
					wren <= 0;
					wait_count <= wait_count + 1;
				end
				WAIT_COPY_I:
				begin
					iterator <= iterator_i;    // may be redundant
					saved_value_i <= q;			// may be redundant
					wait_count <= 2'b0;
				end

				COPY_J:
				begin
					saved_value_j <= q;
					iterator <= iterator_j;
					wren <= 0;
					wait_count <= wait_count + 1;
				end
				WAIT_COPY_J:
				begin
					iterator <= iterator_j;    // may be redundant
					saved_value_j <= q;			// may be redundant
					wait_count <= 2'b0;
				end

				SWAP_I:
				begin
					out_value <= saved_value_j;
					iterator <= iterator_i;
					wren <= 1;
					wait_count <= wait_count + 1;
				end
				WAIT_SWAP_I:
				begin
					//out_value <= saved_value_j;			// may be redundant
					iterator <= iterator_i;					// may be redundant
					wren <= 0;	
					wait_count <= 2'b0;
				end

				SWAP_J:
				begin
					out_value <= saved_value_i;
					iterator <= iterator_j;
					wren <= 1;
					wait_count <= wait_count + 1;
				end
				WAIT_SWAP_J:
				begin
					//out_value <= saved_value_i;			// may be redundant
					iterator <= iterator_j;					// may be redundant
					wren <= 0;
					wait_count <= 2'b0;
				end

				FINISH:
				begin
					fsm_finished <= 1;
					wren <= 0;
					wait_count <= 2'b0;
				end
				
				default: // In case something goes wrong
				begin
					fsm_finished <= 1;
					wren <= 0;
				end
			endcase

		
			state <= next_state;
		end
	end
endmodule