module task2_fsm_ebi_ver 
				(
					input clk,reset,
               input [7:0] secret_key[2:0],
               input logic [7:0] q,
               output logic [7:0] iterator, 
					output logic wren,
					output logic [7:0] out_value
				);
				
logic finish_FSM_1;
logic wren_1, wren_2;
logic [7:0] out_value_1, out_value_2;
logic [7:0] iterator_1, iterator_2;

assign out_value = finish_FSM_1 ? out_value_2 : out_value_1;
assign wren = finish_FSM_1 ? wren_2 : wren_1;
assign iterator= finish_FSM_1 ? iterator_2 : iterator_1;

	task2a_fsm_ebi_ver FSM_1 
		(  // Inputs
			.clk(clk),
		   .reset(reset),
		   .q(q),
			
			// Outputs
		   .iterator(iterator_1),
		   .secret_key(secret_key),
		   .wren(wren_1),
		   .out_value(out_value_1),
		   .finish_FSM_1(finish_FSM_1)
		);

	task2b_fsm_ebi_ver FSM_2
		(   // Inputs
			.clk(clk),
			.reset(reset),
			.q(q),
			
			// Outputs
			.iterator(iterator_2),
			.wren(wren_2),
			.out_value(out_value_2),
			.finish_FSM_1(finish_FSM_1)
		);
		
endmodule					 