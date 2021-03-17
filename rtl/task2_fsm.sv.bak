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

module task2_fsm (	input clk, reset,
							input [7:0] secret_key [2:0],
							input [7:0] q,
							
							output logic [7:0] iterator, out_value,
							output logic wren
						);
					
reg [7:0] iterator_i, iterator_j;
wire [7:0] mods;
parameter END_OF_MSG = 8'hFF;



//Working_mem RAM1(.wen(wen), .q(q), .data(data), .address(addr));

//decrypted_msg RAM2 (.address(addr_d), .data(data_d), .wren(wren_d));

//encrypted_msg ROM (.q(q_m), .address (addr_m));

    reg [7:0]   state;
                                                  //7654_3210
    parameter [7:0] start                       =8'b0000_0001;
    parameter [7:0] Iterate_i                   =8'b0001_0010;
    parameter [7:0] reset_i                     =8'b1100_0011;
    parameter [7:0] load_mem_i                  =8'b1100_0100;
    parameter [7:0] Iterate_j                   =8'b1100_0110;
	 
	 parameter [7:0] Swap_ij                     =8'b1100_0000;

	assign wren= state[4] || request_to_write_loop_2;
	assign mods= secret_key[iterator%3]; // secret_key[i mod keylength]
//	assign key_leng= 3'h3;

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

	always_ff @( posedge clk or negedge reset ) begin : blockName
		if (!reset) begin //resets FSM
			state <= start;
			
			iterator <= 8'h0;
			iterator_i <= 8'h0;
			iterator_j <= 8'h0;
			
			start_loop_2 <= 1'b0;
			reset_loop_2 <= 1'b0;
		end

		else
		case (state)
			start: state <= Iterate_i; //starts FSM

			Iterate_i: begin //
				if (iterator_i == END_OF_MSG)
					state <= reset_i;
				else begin
					state <= Iterate_i;
					iterator_i <= iterator_i + 8'h01;
					iterator <= iterator_i;
					
					out_value <= iterator_i;
				end
			end
			
			reset_i:begin
				iterator <= 8'h0;
				iterator_i <= 8'h0;
				// reset iterator_j as well ???
				state <= load_mem_i;
			end

			load_mem_i:begin
				if(iterator_i == END_OF_MSG)
					state <= start;
				else begin
					state <= Iterate_j;
				end
			end

			Iterate_j:begin
				iterator_j <= iterator_j+ q + mods;
				state <= Swap_ij;
				iterator_i <= iterator_i+8'h01;
				iterator <= iterator_i;
				
				reset_loop_2 <= 1'b1;
				start_loop_2 <= 1'b0;
			end
			
			Swap_ij: begin
				iterator <= requested_iterator_loop_2;
				out_value <= requested_out_value_loop_2;
				
				reset_loop_2 <= 1'b0;
				start_loop_2 <= 1'b1;
				state <= (finished_loop_2) ?  Swap_ij : load_mem_i;
			end

			default: state <= start;
		endcase
		
	end
endmodule
