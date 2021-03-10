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

module task1_fsm (	input clk, reset,
							output logic [7:0] iterator,
							output logic wren
						);
					
	parameter END_OF_MSG = 8'hFF;				
	
	// Defining states
	enum int unsigned { 
		START = 0, 
		ITERATE = 1,
		COMPLETION = 2
		
	} state, next_state;		
	
	// Defining next_state order
	always_comb begin : next_state_logic 
	next_state = START;
		case(state)
				START: 
				begin
					next_state = ITERATE;
				end 
				
				ITERATE: 
				begin
					next_state = (iterator == END_OF_MSG) ? COMPLETION : ITERATE;
				end 
				
				COMPLETION: 
				begin
					next_state = COMPLETION;
				end 
				
			default: next_state = START;
		endcase
	end
	
	// Defining output values
	always_comb 
	begin 
			case(state)
				START: 
				begin	
					wren <= 0;
				end
				
				ITERATE: 
				begin	
					wren <= 1;
				end
				
				COMPLETION: 
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
		end
		
		// If not resetting, normal operation
		else
		begin
			if(state == COMPLETION)
			begin
				iterator <= END_OF_MSG;
			end
			else
			begin
				iterator <= iterator + 8'h01;
			end
		
			state <= next_state;
		end
	end
endmodule