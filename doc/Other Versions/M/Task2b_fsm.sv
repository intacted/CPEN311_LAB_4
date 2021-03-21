module task2b (	input clk, reset, finish_FSM_1,
							input logic [7:0] q,
							output logic [7:0] iterator, 
							output logic wren,
                            output logic [7:0] out_value
						);

logic [7:0] iterator_j;
logic [7:0] addr_d;
logic [7:0] value_i;
logic [7:0] value_j;
logic [7:0] value_f;
logic [7:0] value_k;
logic [7:0] data_d;
logic [7:0] temp,q_d;
logic [7:0] q_m;
logic wren_d;
parameter END_OF_MSG = 8'hFF;

logic [7:0] state;

decrypted_msg RAM2 (.clock(clk), .address(addr_d), .data(data_d), .wren(wren_d), .q(q_d));

encrypted_msg ROM (.clock(clk), .q(q_m), .address (addr_d));

//for k = 0 to message_length-1 { // message_length is 32 in our implementation
// i = i+1
// j = j+s[i]
// swap values of s[i] and s[j]
// f = s[ (s[i]+s[j]) ]
// decrypted_output[k] = f xor encrypted_input[k] // 8 bit wide XOR function
// }
assign wren=state[5];
assign wren_d=state[6];
                                              //765_43210
parameter [7:0] start                       =8'b000_00001;
parameter [7:0] add_i                       =8'b000_00010;
parameter [7:0] wait_s                      =8'b000_00011;
parameter [7:0] add_j                       =8'b000_00100;
//begin swap 
parameter [7:0] wait_load_s_j               =8'b000_00101;
parameter [7:0] wait_load_s_j_2             =8'b000_00110;
parameter [7:0] load_s_j                    =8'b000_00111;
parameter [7:0] place_j                     =8'b001_01000;
parameter [7:0] restore_i                   =8'b000_01001;
parameter [7:0] wait_place_i                =8'b000_01010;
parameter [7:0] place_i                     =8'b001_01011;
//end swap
//begin s[(s[i]+s[j])]
parameter [7:0] wait_load_s_i_j             =8'b000_01100;
parameter [7:0] wait_load_s_i_j_2           =8'b000_01101;
parameter [7:0] load_s_i_j                  =8'b000_01110;
//end s[(s[i]+s[j])]
//begin encrypt/decrypt
parameter [7:0] wait_decrypt                =8'b000_01111;
parameter [7:0] decrypt                     =8'b010_10000;
parameter [7:0] add_k                       =8'b000_10001;
//end
parameter [7:0] finished                    =8'b000_11111;

	always_ff @( posedge clk or posedge  reset or posedge finish_FSM_1) begin : loop3
		if (reset) begin //resets FSM
			iterator <= 8'h00;
			iterator_j <= 8'h00;
			state <= start;
		end

		else
		case (state)
			start:begin
				iterator <= 8'h00;
				iterator_j <= 8'h00;
                addr_d <= 8'h00;
                if (finish_FSM_1)
				    state <= add_i; //starts FSM
                else
                    state <= start;
			end

            add_i:begin
                if (addr_d == 8'h20)
                    state <= finished;
                else begin
                    iterator <= iterator + 8'h01;
                    state <= wait_s;
                end
            end

            wait_s:begin
                temp <= iterator;
                state <= add_j;
            end

            add_j:begin
                iterator_j <= iterator_j+q;
                value_i <= q;
                state <= wait_load_s_j;
            end

            wait_load_s_j: begin
                iterator <= iterator_j;
                state <= wait_load_s_j_2;
            end

            wait_load_s_j_2: begin
                out_value <= value_i;
                state <= load_s_j;
            end

            load_s_j:begin
                value_j <= q;
                state <= place_j;
            end

            place_j:begin
                state <= restore_i;
            end

            restore_i:begin
                out_value <= value_j;
                iterator <= temp;
                state <= wait_place_i;
            end

            wait_place_i:begin
                state <= place_i;
            end

            place_i:begin
                state <=wait_load_s_i_j;
            end

            wait_load_s_i_j:begin
                iterator <=( value_i+value_j);
                value_k <= q_m;
                state <= wait_load_s_i_j_2;
            end

            wait_load_s_i_j_2:begin
                state <= load_s_i_j;
            end

            load_s_i_j:begin
                value_f <= q;
                state <= wait_decrypt;
            end

            wait_decrypt:begin
                data_d <= value_f ^ value_k;
                state <= decrypt;
            end

            decrypt:begin
                state <= add_k;
            end

            add_k:begin
                iterator <= temp;
                addr_d <= addr_d + 8'h01;
                state <= add_i;
            end

			finished:begin
				state <= finished;
			end

			default: state <= start;
		endcase
		
	end
endmodule
