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

/*
architecture rtl of ksa is
   COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;
*/

SevenSegmentDisplayDecoder  sevenseg (.ssOut(),.nIn());
 
//SevenSegmentDisplayDecoder  sevenseg0 (.ssOut(HEX0),.nIn(sseg[3:0]));
//SevenSegmentDisplayDecoder  sevenseg1 (.ssOut(HEX1),.nIn(sseg[7:4]));
//SevenSegmentDisplayDecoder  sevenseg2 (.ssOut(HEX2),.nIn(sseg[11:8]));
//SevenSegmentDisplayDecoder  sevenseg3 (.ssOut(HEX3),.nIn(sseg[15:12]));
//SevenSegmentDisplayDecoder  sevenseg4 (.ssOut(HEX4),.nIn(sseg[19:16]));
//SevenSegmentDisplayDecoder  sevenseg5 (.ssOut(HEX5),.nIn(sseg[23:20]));  
   
logic [7:0] iterator;
logic q, wren;	

// -- clock and reset signals  
logic clk, reset_n;										

//always_ff@(posedge clk or posedge reset_n)
//always_comb
//begin

    assign clk = CLOCK_50;
    assign reset_n = KEY[3];
	 
	 task1_fsm pass_through_values(
		.clk(clk),
		.iterator(iterator),
		.reset(reset_n),
		.wren(wren)
	 );
	 
	 s_memory output_to_S(
		.address(iterator),
		.clock(clk),         // double check if this is the correct clock
		.data(iterator),		// figure out what this should be
		.wren(wren),
		.q(q)
	 );
	 
//end
	 
endmodule