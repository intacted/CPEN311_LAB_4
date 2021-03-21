`default_nettype none

module ksa(
    input CLOCK_50, 				// -- Clock pin
    input[3:0] KEY, 				// -- push button switches
    input[9:0] SW,      	   // -- slider switches
    output logic[9:0] LEDR,	// -- red lights
    output logic[6:0] HEX0, 
    output logic[6:0] HEX1, 
    output logic[6:0] HEX2, 
    output logic[6:0] HEX3, 
    output logic[6:0] HEX4, 
    output logic[6:0] HEX5 
);

	SevenSegmentDisplayDecoder  sevenseg0 (.ssOut(HEX0),.nIn(secret_key[3:0]));
	SevenSegmentDisplayDecoder  sevenseg1 (.ssOut(HEX1),.nIn(secret_key[7:4]));
	SevenSegmentDisplayDecoder  sevenseg2 (.ssOut(HEX2),.nIn(secret_key[11:8]));
	SevenSegmentDisplayDecoder  sevenseg3 (.ssOut(HEX3),.nIn(secret_key[15:12]));
	SevenSegmentDisplayDecoder  sevenseg4 (.ssOut(HEX4),.nIn(secret_key[19:16]));
	SevenSegmentDisplayDecoder  sevenseg5 (.ssOut(HEX5),.nIn(secret_key[23:20]));  
	
	// -- clock and reset signals  
	logic clk, reset_n;										

   assign clk = CLOCK_50;
   assign reset_n = KEY[3]; // ? 1'b1 : 1'b0 ;
	
	/*
	// TASK 3 WITH BONUS CODE
	logic [23:0] secret_key;
	
	task3_fsm pass_through_values(
		// Inputs
		.clk(clk),
		.reset(!reset_n),
		
		// Outputs
		.secret_key(secret_key)
	);
	*/
	
	// TASK 3 CODE
	logic [7:0] iterator, q;
	logic [7:0] out_value;
	logic wren;	
	
	logic [23:0] secret_key;
	
	task3_fsm pass_through_values(
		// Inputs
		.clk(clk),
		.reset(!reset_n),
		//.secret_key(key),
		.q(q),
		
		// Outputs
		.iterator(iterator),
		.secret_key(secret_key),
		.out_value(out_value),
		.wren(wren)
	);
	
	s_memory output_to_S(
		.address(iterator),
		.clock(clk),         
		.data(out_value),		
		.wren(wren),
		.q(q)
	);
	
	/*
	// TASK 2 CODE
	logic [7:0] iterator, q;
	logic [7:0] out_value;
	logic wren;	
	
	//parameter logic [7:0] key [2:0]= '{8'h49,8'h02,8'h00}; //'{8'hAA, 8'h02, 8'h00}; //'{8'hFF,8'h03,8'h00}; //'{8'h49,8'h02,8'h00};
	logic [7:0] key [2:0];
	assign key = '{SW[7:0],{4'h00, SW[9:8]},8'h00}; 
	
	
	task2_fsm decryption_module(
		// Inputs
		.clk(clk),
		.reset(reset_n),
		.start_FSM_1(1'b1),
		.secret_key(key),
		.q(q),
		
		// Outputs
		.iterator(iterator),
		.out_value(out_value),
		.wren(wren),
		.failed_decrypt(),			// For task 3
		.done_decrypt()				// For task 3
	);
	
	s_memory output_to_S(
		.address(iterator),
		.clock(clk),         
		.data(out_value),		
		.wren(wren),
		.q(q)
	);
	*/
	 
endmodule