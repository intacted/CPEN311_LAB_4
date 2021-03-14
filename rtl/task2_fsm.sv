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
							output logic [7:0] iterator, 
							output logic wren
						);
					
reg [7:0] iterator_j;
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

	assign wren=state[4];
	assign mods= secret_key[iterator%3]; // secret_key[i mod keylength]
//	assign key_leng= 3'h3;

	always_ff @( posedge clk or negedge reset ) begin : blockName
		if (!reset) begin //resets FSM
			state <= start;
			iterator <= 8'h0;
			iterator_j <= 8'h0;
		end

		else
		case (state)
			start: state <= Iterate_i; //starts FSM

			Iterate_i: begin //
				if (iterator == END_OF_MSG)
					state <= reset_i;
				else begin
					state <= Iterate_i;
					iterator <= iterator + 8'h01;
				end
			end
			
			reset_i:begin
				iterator <= 8'h0;
				state <= load_mem_i;
			end

			load_mem_i:begin
				if(iterator == END_OF_MSG)
					state <= start;
				else begin
					state <= Iterate_j;
				end
			end

			Iterate_j:begin
				iterator_j <= iterator_j+ q + mods;
				state <= load_mem_i;
				iterator <= iterator+8'h01;
			end

			default: state <= start;
		endcase
		
	end
endmodule
