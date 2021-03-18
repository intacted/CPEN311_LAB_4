//=====================================================================================
//
// Multiplexer Section (4-1), binary select
//
//=====================================================================================
module mux4_binary_select
		#(parameter N = 32) 
			(input logic [N-1:0] a0, a1, a2, a3,
						input logic [2:0] select,
						output logic [N-1:0] out);
						
						always @(*)
						case(select)
							0: out = a0;
							1: out = a1;
							2: out = a2;
							3: out = a3;
							default: out = 0;
						endcase
endmodule

//=====================================================================================
//
// Multiplexer Section (4-1), one hot select
//
//=====================================================================================
module mux_one_hot_select
		#(parameter BIT_WIDTH = 8, INPUT_NUMBER = 4) 
			(
				input logic [BIT_WIDTH-1:0] a [INPUT_NUMBER-1:0],
				input logic [INPUT_NUMBER-1:0] select,
				output logic [BIT_WIDTH-1:0] out
			);
						
						 
	always_comb 
	begin
		// Default high-impedance
		out = 'z;
		
		// Choose selected input for writing
		for(int i = 0; i < INPUT_NUMBER; i++) 
		begin
			if (select == (1 << i))
				out = a[i];
		end
	end
endmodule