// Pretty much the same as the DE1 except writes are instantaneous instead of delayed
module RAM(address, clock, data, wren, q);
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 256;

    input [ADDR_WIDTH - 1:0] address;
    input clock;
    input [DATA_WIDTH - 1:0] data;
    input wren;
    output reg [DATA_WIDTH - 1:0] q;

    reg [DATA_WIDTH - 1:0] temp_data;
    reg [DATA_WIDTH - 1:0] mem [0:DEPTH-1];

    always @(posedge clock) begin
       if (wren) mem[address] <= data;
       
       q <= mem[address];
    end

endmodule

