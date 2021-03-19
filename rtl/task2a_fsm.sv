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

module task2a_fsm (	input clk, reset,
							input [7:0] secret_key [2:0],
							input logic [7:0] q,
							output logic [7:0] iterator, 
							output logic wren,
							output logic [7:0] out_value,
							output logic finish_FSM_1
						);
					
logic [7:0] iterator_j,value_i, value_j,temp;
logic [7:0] mods;
parameter END_OF_MSG = 8'hFF;
logic finish_loop;



    reg [8:0]   state;
                                                  //8765_43210
    parameter [8:0] start                       =9'b0000_00001;
	parameter [8:0] loop_1              	    =9'b0001_00010;
    parameter [8:0] Iterate_i                   =9'b0001_00011;
	parameter [8:0] intilize_mem				=9'b0000_00100;
    parameter [8:0] reset_i                     =9'b0000_00101;
	parameter [8:0] load_s						=9'b0000_00110;
    parameter [8:0] load_mem_i                  =9'b0000_00111;
	parameter [8:0] wait_grab_j				    =9'b0000_01000;
	parameter [8:0] wait_2_grab_j				=9'b0000_01001;
	parameter [8:0] grab_j						=9'b0000_01010;
	parameter [8:0] wait_place_j				=9'b0000_01011;
	parameter [8:0] place_j						=9'b0001_01100;
	parameter [8:0] replace_i					=9'b0000_01101 ;
	parameter [8:0] wait_place_i				=9'b0000_01110;
	parameter [8:0] place_i						=9'b0001_01111;
	parameter [8:0] load_j_i   					=9'b0000_10000;
	parameter [8:0] finished					=9'b1000_11111;


	assign finish_FSM_1=state[8];
	assign wren=state[5];
	//assign read_write=state[6];

	//assign q= read_write?out_value:8'bz;
//	assign mods= secret_key[iterator%3]; // secret_key[i mod keylength]
//	assign key_leng= 3'h4;

	always_ff @( posedge clk or posedge  reset ) begin : blockName
		if (reset) begin //resets FSM
			finish_loop <= 1'b0;
			iterator <= 8'h00;
			iterator_j <= 8'h00;
			state <= start;
		end

		else
		case (state)
			start:begin
				finish_loop <= 1'b0;
				iterator <= 8'h00;
				iterator_j <= 8'h00;
				state <= loop_1; //starts FSM
			end

			loop_1:begin
				out_value <= iterator;
				state <= intilize_mem;
			end

			Iterate_i: begin //
				if (iterator == END_OF_MSG)
					state <= reset_i;
				else begin
					out_value <= iterator;
					iterator <= iterator + 8'h01;
					state <= intilize_mem;
				end
			end

			intilize_mem:begin
				out_value <= iterator;
				state <= Iterate_i;
			end

			
			reset_i:begin
				iterator <= 8'h00;
				state <= load_s;
			end

			load_s:begin
				state <= load_mem_i;
			end

			load_mem_i:begin
				if(iterator == END_OF_MSG)
					finish_loop <= 1'b1;
				begin
					iterator_j <= iterator_j+ q + secret_key[iterator%3];
					mods <= secret_key[iterator%3]; //for debugging
					value_i <= q;
					temp <= iterator;
					state <= wait_grab_j;
				end
			end

//			Iterate_j:begin				
//				iterator_j <= iterator_j+ q + mods;
//				state <= grab_i;
				//iterator <= iterator+8'h01;
//			end

			wait_grab_j:begin
				iterator <= iterator_j;
				state <= wait_2_grab_j;
			end

			wait_2_grab_j:begin
				out_value <= value_i;
				state <= grab_j;
			end

			grab_j:begin
				value_j <= q;
				state <= wait_place_j;
			end

			wait_place_j:begin
				state <= place_j;
			end

			place_j:begin
				state <= replace_i;
			end

			replace_i:begin
				iterator <= temp;
				state <= wait_place_i;
			end

			wait_place_i:begin
				out_value <= value_j;
				state <= place_i;
			end

			place_i:begin
				state <= load_j_i;
			end
			
			load_j_i:begin
				if (finish_loop==1'b1)
					state <= finished;
				else begin
					iterator <= iterator+8'h01;
					state <= load_s;
				end
			end

			finished:begin
				state <= finished;
			end

			default: state <= start;
		endcase
		
	end
endmodule
